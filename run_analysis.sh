#!/bin/bash

# =============================================================================
# LAB ANALYSIS PIPELINE WRAPPER SCRIPT
# =============================================================================
# This script provides an easy way to run the complete lab analysis pipeline
# with common configurations.
#
# Usage: ./run_analysis.sh [command] [options]
#
# Commands:
#   prepare              Run data preparation only
#   analyze              Run lab analysis only (requires prepared data)
#   full                 Run complete pipeline (prepare + analyze)
#   help                 Show this help message
#
# Examples:
#   # Run complete pipeline with 5 patients (testing)
#   ./run_analysis.sh full --n_patients 5
#
#   # Run complete pipeline with all patients
#   ./run_analysis.sh full --n_patients all
#
#   # Run only data preparation
#   ./run_analysis.sh prepare --input_dir /path/to/data
#
#   # Run only lab analysis
#   ./run_analysis.sh analyze --input_dir ./prepared_data --n_patients 10
#
# =============================================================================

set -e  # Exit on any error

# Default values
INPUT_DIR=""
OUTPUT_DIR="./prepared_data"
N_PATIENTS="5"
MAX_DATE_DIFF="365"
REMOVE_DIGIT_COLS="true"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_help() {
    cat << EOF
LAB ANALYSIS PIPELINE WRAPPER SCRIPT
====================================

This script provides an easy way to run the complete lab analysis pipeline
with common configurations.

USAGE:
    ./run_analysis.sh [command] [options]

COMMANDS:
    prepare              Run data preparation only
    analyze              Run lab analysis only (requires prepared data)
    full                 Run complete pipeline (prepare + analyze)
    help                 Show this help message

OPTIONS:
    --input_dir DIR      Input directory containing raw data files
    --output_dir DIR     Output directory for results (default: ./prepared_data)
    --n_patients N       Number of patients to process (default: 5, use 'all' for all)
    --max_date_diff N    Maximum date difference in days (default: 365)
    --no_remove_digits   Don't remove digit-only columns

EXAMPLES:
    # Run complete pipeline with 5 patients (testing)
    ./run_analysis.sh full --n_patients 5

    # Run complete pipeline with all patients
    ./run_analysis.sh full --n_patients all

    # Run only data preparation
    ./run_analysis.sh prepare --input_dir /path/to/data

    # Run only lab analysis
    ./run_analysis.sh analyze --input_dir ./prepared_data --n_patients 10

    # Run with custom settings
    ./run_analysis.sh full --input_dir /data --output_dir ./results --n_patients 100 --max_date_diff 180

REQUIREMENTS:
    - R with data.table and argparse packages
    - Raw data files in input directory:
      * cohortmrn_merge.data.csv
      * OUTPT_LAB_RESULTS_LABS.csv
      * CANCER_DIAGNOSIS_CAREG.csv

OUTPUT:
    - Prepared data RDS files (from prepare command)
    - Lab analysis results (from analyze command)
    - Summary reports and statistics

EOF
}

# Parse command line arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        prepare|analyze|full|help)
            COMMAND="$1"
            shift
            ;;
        --input_dir)
            INPUT_DIR="$2"
            shift 2
            ;;
        --output_dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --n_patients)
            N_PATIENTS="$2"
            shift 2
            ;;
        --max_date_diff)
            MAX_DATE_DIFF="$2"
            shift 2
            ;;
        --no_remove_digits)
            REMOVE_DIGIT_COLS="false"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if command is provided
if [[ -z "$COMMAND" ]]; then
    print_error "No command provided"
    show_help
    exit 1
fi

# Check if R is available
if ! command -v Rscript &> /dev/null; then
    print_error "Rscript not found. Please install R and ensure Rscript is in your PATH."
    exit 1
fi

# Check if required R packages are available
print_header "CHECKING REQUIREMENTS"
if ! Rscript -e "suppressPackageStartupMessages({library(data.table); library(argparse)})" 2>/dev/null; then
    print_error "Required R packages not found. Please install data.table and argparse packages."
    print_warning "Run: Rscript -e \"install.packages(c('data.table', 'argparse'))\""
    exit 1
fi
print_success "R and required packages are available"

# Function to run data preparation
run_prepare() {
    print_header "RUNNING DATA PREPARATION"
    
    if [[ -z "$INPUT_DIR" ]]; then
        print_error "Input directory not specified for data preparation"
        exit 1
    fi
    
    if [[ ! -d "$INPUT_DIR" ]]; then
        print_error "Input directory does not exist: $INPUT_DIR"
        exit 1
    fi
    
    print_success "Starting data preparation..."
    print_success "Input directory: $INPUT_DIR"
    print_success "Output directory: $OUTPUT_DIR"
    
    Rscript 01_data_preparation.R \
        --input_dir "$INPUT_DIR" \
        --output_dir "$OUTPUT_DIR"
    
    if [[ $? -eq 0 ]]; then
        print_success "Data preparation completed successfully"
    else
        print_error "Data preparation failed"
        exit 1
    fi
}

# Function to run lab analysis
run_analyze() {
    print_header "RUNNING LAB ANALYSIS"
    
    if [[ -z "$INPUT_DIR" ]]; then
        print_error "Input directory not specified for lab analysis"
        exit 1
    fi
    
    if [[ ! -d "$INPUT_DIR" ]]; then
        print_error "Input directory does not exist: $INPUT_DIR"
        exit 1
    fi
    
    # Check if required RDS files exist
    required_files=("cohort.rds" "lab_subset.rds" "cancer_subset.rds")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$INPUT_DIR/$file" ]]; then
            print_error "Required RDS file not found: $INPUT_DIR/$file"
            print_warning "Please run data preparation first: ./run_analysis.sh prepare --input_dir <raw_data_dir>"
            exit 1
        fi
    done
    
    print_success "Starting lab analysis..."
    print_success "Input directory: $INPUT_DIR"
    print_success "Output directory: $OUTPUT_DIR"
    print_success "Number of patients: $N_PATIENTS"
    print_success "Max date difference: $MAX_DATE_DIFF days"
    print_success "Remove digit columns: $REMOVE_DIGIT_COLS"
    
    Rscript 02_lab_analysis.R \
        --input_dir "$INPUT_DIR" \
        --n_patients "$N_PATIENTS" \
        --output_dir "$OUTPUT_DIR" \
        --max_date_diff "$MAX_DATE_DIFF" \
        $([ "$REMOVE_DIGIT_COLS" = "true" ] && echo "--remove_digit_cols")
    
    if [[ $? -eq 0 ]]; then
        print_success "Lab analysis completed successfully"
    else
        print_error "Lab analysis failed"
        exit 1
    fi
}

# Function to run complete pipeline
run_full() {
    print_header "RUNNING COMPLETE PIPELINE"
    
    if [[ -z "$INPUT_DIR" ]]; then
        print_error "Input directory not specified for complete pipeline"
        exit 1
    fi
    
    # Step 1: Data preparation
    run_prepare
    
    # Step 2: Lab analysis
    run_analyze
    
    print_header "PIPELINE COMPLETED SUCCESSFULLY"
    print_success "All steps completed successfully"
    print_success "Results are available in: $OUTPUT_DIR"
}

# Main execution
case $COMMAND in
    prepare)
        run_prepare
        ;;
    analyze)
        run_analyze
        ;;
    full)
        run_full
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

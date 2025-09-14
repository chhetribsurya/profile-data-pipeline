#!/bin/bash

# =============================================================================
# BASIC USAGE EXAMPLES
# =============================================================================
# This script demonstrates basic usage patterns for the Clinical Lab Analysis Pipeline.
#
# Prerequisites:
# - R with required packages installed
# - Example data files in example_data/ directory
# - Pipeline scripts in the root directory
#
# Usage: ./examples/basic_usage.sh
#
# =============================================================================

set -e  # Exit on any error

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

# Check prerequisites
check_prerequisites() {
    print_header "CHECKING PREREQUISITES"
    
    # Check if R is available
    if ! command -v Rscript &> /dev/null; then
        print_error "Rscript not found. Please install R and ensure Rscript is in your PATH."
        exit 1
    fi
    print_success "R is available"
    
    # Check if example data exists
    if [ ! -d "example_data" ]; then
        print_error "Example data directory not found. Please ensure example_data/ exists."
        exit 1
    fi
    print_success "Example data directory found"
    
    # Check if required CSV files exist
    required_files=("cohortmrn_merge.data.csv" "OUTPT_LAB_RESULTS_LABS.csv" "CANCER_DIAGNOSIS_CAREG.csv")
    for file in "${required_files[@]}"; do
        if [ ! -f "example_data/$file" ]; then
            print_error "Required file not found: example_data/$file"
            exit 1
        fi
    done
    print_success "All required example data files found"
    
    # Check if pipeline scripts exist
    if [ ! -f "run_analysis.sh" ]; then
        print_error "Pipeline wrapper script not found: run_analysis.sh"
        exit 1
    fi
    print_success "Pipeline scripts found"
    
    # Make scripts executable
    chmod +x run_analysis.sh
    print_success "Scripts made executable"
}

# Example 1: Basic pipeline with 5 patients
example_1() {
    print_header "EXAMPLE 1: Basic Pipeline with 5 Patients"
    
    echo "Running complete pipeline with 5 patients..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 5"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 5
    
    if [ $? -eq 0 ]; then
        print_success "Example 1 completed successfully"
    else
        print_error "Example 1 failed"
        return 1
    fi
}

# Example 2: Pipeline with all patients
example_2() {
    print_header "EXAMPLE 2: Pipeline with All Patients"
    
    echo "Running complete pipeline with all patients..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients all"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients all
    
    if [ $? -eq 0 ]; then
        print_success "Example 2 completed successfully"
    else
        print_error "Example 2 failed"
        return 1
    fi
}

# Example 3: Custom output directory
example_3() {
    print_header "EXAMPLE 3: Custom Output Directory"
    
    echo "Running pipeline with custom output directory..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --output_dir ./custom_results --n_patients 10"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --output_dir ./custom_results --n_patients 10
    
    if [ $? -eq 0 ]; then
        print_success "Example 3 completed successfully"
        echo "Results saved to: ./custom_results"
    else
        print_error "Example 3 failed"
        return 1
    fi
}

# Example 4: Step-by-step processing
example_4() {
    print_header "EXAMPLE 4: Step-by-Step Processing"
    
    echo "Step 1: Data preparation only..."
    echo "Command: ./run_analysis.sh prepare --input_dir example_data --output_dir ./step1_output"
    echo ""
    
    ./run_analysis.sh prepare --input_dir example_data --output_dir ./step1_output
    
    if [ $? -eq 0 ]; then
        print_success "Step 1 (data preparation) completed successfully"
    else
        print_error "Step 1 (data preparation) failed"
        return 1
    fi
    
    echo ""
    echo "Step 2: Lab analysis only..."
    echo "Command: ./run_analysis.sh analyze --input_dir ./step1_output --n_patients 15 --output_dir ./step2_output"
    echo ""
    
    ./run_analysis.sh analyze --input_dir ./step1_output --n_patients 15 --output_dir ./step2_output
    
    if [ $? -eq 0 ]; then
        print_success "Step 2 (lab analysis) completed successfully"
        echo "Results saved to: ./step2_output"
    else
        print_error "Step 2 (lab analysis) failed"
        return 1
    fi
}

# Example 5: Different date windows
example_5() {
    print_header "EXAMPLE 5: Different Date Windows"
    
    echo "Running with 6-month date window..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 8 --max_date_diff 180 --output_dir ./results_6month"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 8 --max_date_diff 180 --output_dir ./results_6month
    
    if [ $? -eq 0 ]; then
        print_success "Example 5 (6-month window) completed successfully"
        echo "Results saved to: ./results_6month"
    else
        print_error "Example 5 (6-month window) failed"
        return 1
    fi
    
    echo ""
    echo "Running with 1-year date window (default)..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 8 --max_date_diff 365 --output_dir ./results_1year"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 8 --max_date_diff 365 --output_dir ./results_1year
    
    if [ $? -eq 0 ]; then
        print_success "Example 5 (1-year window) completed successfully"
        echo "Results saved to: ./results_1year"
    else
        print_error "Example 5 (1-year window) failed"
        return 1
    fi
}

# Example 6: Caching system demonstration
example_6() {
    print_header "EXAMPLE 6: Caching System Demonstration"
    
    echo "First run - full processing..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo
    
    if [ $? -eq 0 ]; then
        print_success "First run completed successfully"
    else
        print_error "First run failed"
        return 1
    fi
    
    echo ""
    echo "Second run - should load from cache (instant!)..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo
    
    if [ $? -eq 0 ]; then
        print_success "Second run completed successfully (loaded from cache)"
    else
        print_error "Second run failed"
        return 1
    fi
    
    echo ""
    echo "Third run - force reprocessing..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo --force_reprocess"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 5 --output_dir ./cache_demo --force_reprocess
    
    if [ $? -eq 0 ]; then
        print_success "Third run completed successfully (forced reprocessing)"
    else
        print_error "Third run failed"
        return 1
    fi
}

# Example 7: New output formats demonstration
example_7() {
    print_header "EXAMPLE 7: New Output Formats Demonstration"
    
    echo "Running pipeline to demonstrate new output formats..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 10 --output_dir ./new_formats_demo"
    echo ""
    
    ./run_analysis.sh full --input_dir example_data --n_patients 10 --output_dir ./new_formats_demo
    
    if [ $? -eq 0 ]; then
        print_success "New formats demonstration completed successfully"
        echo "Results saved to: ./new_formats_demo"
        
        echo ""
        echo "New output files created:"
        echo "  ✓ lab_result_matrix.csv (deduplicated wide format)"
        echo "  ✓ lab_date_matrix.csv (deduplicated wide format dates)"
        echo "  ✓ detailed_lab_results.csv (deduplicated long format)"
        echo "  ✓ lab_results_long_format.csv (all data long format)"
        echo "  ✓ lab_result_matrix_with_suffixes.csv (wide format with MRN suffixes)"
        echo "  ✓ lab_date_matrix_with_suffixes.csv (wide format dates with suffixes)"
        echo "  ✓ summary_statistics.csv (analysis summary)"
        echo "  ✓ lab_analysis_summary.txt (text summary)"
    else
        print_error "New formats demonstration failed"
        return 1
    fi
}

# Show results summary
show_results() {
    print_header "RESULTS SUMMARY"
    
    echo "Output directories created:"
    for dir in prepared_data lab_analysis_results custom_results step1_output step2_output results_6month results_1year cache_demo new_formats_demo; do
        if [ -d "$dir" ]; then
            echo "  ✓ $dir"
            echo "    Files: $(ls -1 $dir | wc -l)"
        else
            echo "  ✗ $dir (not found)"
        fi
    done
    
    echo ""
    echo "Key output files:"
    for dir in prepared_data lab_analysis_results custom_results step2_output results_6month results_1year cache_demo new_formats_demo; do
        if [ -d "$dir" ]; then
            echo "  $dir/:"
            if [ -f "$dir/lab_result_matrix.csv" ]; then
                echo "    ✓ lab_result_matrix.csv (deduplicated wide format)"
            fi
            if [ -f "$dir/lab_date_matrix.csv" ]; then
                echo "    ✓ lab_date_matrix.csv (deduplicated wide format dates)"
            fi
            if [ -f "$dir/detailed_lab_results.csv" ]; then
                echo "    ✓ detailed_lab_results.csv (deduplicated long format)"
            fi
            if [ -f "$dir/lab_results_long_format.csv" ]; then
                echo "    ✓ lab_results_long_format.csv (all data long format)"
            fi
            if [ -f "$dir/lab_result_matrix_with_suffixes.csv" ]; then
                echo "    ✓ lab_result_matrix_with_suffixes.csv (wide format with MRN suffixes)"
            fi
            if [ -f "$dir/lab_date_matrix_with_suffixes.csv" ]; then
                echo "    ✓ lab_date_matrix_with_suffixes.csv (wide format dates with suffixes)"
            fi
            if [ -f "$dir/summary_statistics.csv" ]; then
                echo "    ✓ summary_statistics.csv (analysis summary)"
            fi
            if [ -f "$dir/lab_analysis_summary.txt" ]; then
                echo "    ✓ lab_analysis_summary.txt (text summary)"
            fi
        fi
    done
}

# Cleanup function
cleanup() {
    print_header "CLEANUP"
    
    echo "Cleaning up temporary directories..."
    
    # Remove temporary directories
    for dir in custom_results step1_output step2_output results_6month results_1year cache_demo new_formats_demo; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo "  Removed: $dir"
        fi
    done
    
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_header "CLINICAL LAB ANALYSIS PIPELINE - BASIC USAGE EXAMPLES"
    
    echo "This script demonstrates basic usage patterns for the Clinical Lab Analysis Pipeline."
    echo "It will run several examples and show you how to use the pipeline effectively."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    echo ""
    echo "Starting examples..."
    echo ""
    
    # Run examples
    example_1
    echo ""
    
    example_2
    echo ""
    
    example_3
    echo ""
    
    example_4
    echo ""
    
    example_5
    echo ""
    
    example_6
    echo ""
    
    example_7
    echo ""
    
    # Show results
    show_results
    
    echo ""
    print_header "EXAMPLES COMPLETED SUCCESSFULLY"
    print_success "All basic usage examples completed successfully!"
    print_success "You can now use the pipeline with your own data."
    
    echo ""
    echo "Next steps:"
    echo "1. Replace example_data/ with your actual data files"
    echo "2. Run the pipeline with your data"
    echo "3. Check the output files for results"
    echo "4. Refer to the main README.md for advanced usage"
    
    # Ask if user wants to cleanup
    echo ""
    read -p "Do you want to cleanup temporary directories? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    else
        echo "Temporary directories left for inspection."
    fi
}

# Run main function
main "$@"

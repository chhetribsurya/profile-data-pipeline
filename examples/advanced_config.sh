#!/bin/bash

# =============================================================================
# ADVANCED CONFIGURATION EXAMPLES
# =============================================================================
# This script demonstrates advanced configuration options for the Clinical Lab Analysis Pipeline.
#
# Prerequisites:
# - R with required packages installed
# - Example data files in example_data/ directory
# - Pipeline scripts in the root directory
#
# Usage: ./examples/advanced_config.sh
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

# Example 1: Custom date windows
example_1() {
    print_header "EXAMPLE 1: Custom Date Windows"
    
    echo "Testing different date windows to find optimal settings..."
    echo ""
    
    # 3-month window
    echo "1. Running with 3-month date window..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 90 --output_dir ./results_3month"
    ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 90 --output_dir ./results_3month
    
    if [ $? -eq 0 ]; then
        print_success "3-month window completed successfully"
    else
        print_error "3-month window failed"
        return 1
    fi
    
    # 6-month window
    echo ""
    echo "2. Running with 6-month date window..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 180 --output_dir ./results_6month"
    ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 180 --output_dir ./results_6month
    
    if [ $? -eq 0 ]; then
        print_success "6-month window completed successfully"
    else
        print_error "6-month window failed"
        return 1
    fi
    
    # 1-year window (default)
    echo ""
    echo "3. Running with 1-year date window (default)..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 365 --output_dir ./results_1year"
    ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 365 --output_dir ./results_1year
    
    if [ $? -eq 0 ]; then
        print_success "1-year window completed successfully"
    else
        print_error "1-year window failed"
        return 1
    fi
    
    # 2-year window
    echo ""
    echo "4. Running with 2-year date window..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 730 --output_dir ./results_2year"
    ./run_analysis.sh full --input_dir example_data --n_patients 10 --max_date_diff 730 --output_dir ./results_2year
    
    if [ $? -eq 0 ]; then
        print_success "2-year window completed successfully"
    else
        print_error "2-year window failed"
        return 1
    fi
}

# Example 2: Column filtering options
example_2() {
    print_header "EXAMPLE 2: Column Filtering Options"
    
    echo "Testing different column filtering options..."
    echo ""
    
    # Keep digit columns
    echo "1. Running without removing digit columns..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 8 --no_remove_digits --output_dir ./results_keep_digits"
    ./run_analysis.sh full --input_dir example_data --n_patients 8 --no_remove_digits --output_dir ./results_keep_digits
    
    if [ $? -eq 0 ]; then
        print_success "Keep digits option completed successfully"
    else
        print_error "Keep digits option failed"
        return 1
    fi
    
    # Remove digit columns (default)
    echo ""
    echo "2. Running with removing digit columns (default)..."
    echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients 8 --output_dir ./results_remove_digits"
    ./run_analysis.sh full --input_dir example_data --n_patients 8 --output_dir ./results_remove_digits
    
    if [ $? -eq 0 ]; then
        print_success "Remove digits option completed successfully"
    else
        print_error "Remove digits option failed"
        return 1
    fi
}

# Example 3: Batch processing
example_3() {
    print_header "EXAMPLE 3: Batch Processing"
    
    echo "Demonstrating batch processing with different patient counts..."
    echo ""
    
    # Process in batches
    for batch_size in 5 10 15 20; do
        echo "Processing batch of $batch_size patients..."
        echo "Command: ./run_analysis.sh full --input_dir example_data --n_patients $batch_size --output_dir ./batch_$batch_size"
        
        ./run_analysis.sh full --input_dir example_data --n_patients $batch_size --output_dir ./batch_$batch_size
        
        if [ $? -eq 0 ]; then
            print_success "Batch $batch_size completed successfully"
        else
            print_error "Batch $batch_size failed"
            return 1
        fi
        
        echo ""
    done
}

# Example 4: Memory optimization
example_4() {
    print_header "EXAMPLE 4: Memory Optimization"
    
    echo "Demonstrating memory optimization techniques..."
    echo ""
    
    # Step 1: Prepare data once
    echo "1. Preparing data once for reuse..."
    echo "Command: ./run_analysis.sh prepare --input_dir example_data --output_dir ./shared_prepared_data"
    ./run_analysis.sh prepare --input_dir example_data --output_dir ./shared_prepared_data
    
    if [ $? -eq 0 ]; then
        print_success "Data preparation completed successfully"
    else
        print_error "Data preparation failed"
        return 1
    fi
    
    # Step 2: Run multiple analyses on prepared data
    echo ""
    echo "2. Running multiple analyses on prepared data..."
    
    for analysis in "small" "medium" "large"; do
        case $analysis in
            "small")
                n_patients=5
                max_date_diff=90
                ;;
            "medium")
                n_patients=15
                max_date_diff=180
                ;;
            "large")
                n_patients=25
                max_date_diff=365
                ;;
        esac
        
        echo "  Running $analysis analysis ($n_patients patients, $max_date_diff days)..."
        echo "  Command: ./run_analysis.sh analyze --input_dir ./shared_prepared_data --n_patients $n_patients --max_date_diff $max_date_diff --output_dir ./analysis_$analysis"
        
        ./run_analysis.sh analyze --input_dir ./shared_prepared_data --n_patients $n_patients --max_date_diff $max_date_diff --output_dir ./analysis_$analysis
        
        if [ $? -eq 0 ]; then
            print_success "$analysis analysis completed successfully"
        else
            print_error "$analysis analysis failed"
            return 1
        fi
        
        echo ""
    done
}

# Example 5: Custom file names
example_5() {
    print_header "EXAMPLE 5: Custom File Names"
    
    echo "Demonstrating custom file names and paths..."
    echo ""
    
    # Create custom data directory
    mkdir -p ./custom_data
    cp example_data/*.csv ./custom_data/
    
    # Rename files to custom names
    mv ./custom_data/cohortmrn_merge.data.csv ./custom_data/my_cohort.csv
    mv ./custom_data/OUTPT_LAB_RESULTS_LABS.csv ./custom_data/my_labs.csv
    mv ./custom_data/CANCER_DIAGNOSIS_CAREG.csv ./custom_data/my_cancer.csv
    
    echo "1. Running with custom file names..."
    echo "Command: Rscript 01_data_preparation.R --cohort_file my_cohort.csv --lab_file my_labs.csv --cancer_file my_cancer.csv --input_dir ./custom_data --output_dir ./custom_prepared"
    
    Rscript 01_data_preparation.R --cohort_file my_cohort.csv --lab_file my_labs.csv --cancer_file my_cancer.csv --input_dir ./custom_data --output_dir ./custom_prepared
    
    if [ $? -eq 0 ]; then
        print_success "Custom file names completed successfully"
    else
        print_error "Custom file names failed"
        return 1
    fi
    
    echo ""
    echo "2. Running lab analysis on custom prepared data..."
    echo "Command: Rscript 02_lab_analysis.R --input_dir ./custom_prepared --n_patients 12 --output_dir ./custom_results"
    
    Rscript 02_lab_analysis.R --input_dir ./custom_prepared --n_patients 12 --output_dir ./custom_results
    
    if [ $? -eq 0 ]; then
        print_success "Custom lab analysis completed successfully"
    else
        print_error "Custom lab analysis failed"
        return 1
    fi
}

# Example 6: Performance monitoring
example_6() {
    print_header "EXAMPLE 6: Performance Monitoring"
    
    echo "Demonstrating performance monitoring techniques..."
    echo ""
    
    # Monitor memory usage
    echo "1. Running with memory monitoring..."
    echo "Command: time ./run_analysis.sh full --input_dir example_data --n_patients 20 --output_dir ./perf_results"
    
    # Use time command to monitor performance
    time ./run_analysis.sh full --input_dir example_data --n_patients 20 --output_dir ./perf_results
    
    if [ $? -eq 0 ]; then
        print_success "Performance monitoring completed successfully"
    else
        print_error "Performance monitoring failed"
        return 1
    fi
    
    echo ""
    echo "2. Checking output file sizes..."
    echo "Output directory contents:"
    ls -lh ./perf_results/
    
    echo ""
    echo "3. Checking RDS file sizes..."
    echo "RDS files:"
    find ./perf_results -name "*.rds" -exec ls -lh {} \;
}

# Show results comparison
show_results() {
    print_header "RESULTS COMPARISON"
    
    echo "Comparing results from different configurations..."
    echo ""
    
    # Compare date window results
    echo "Date window comparison:"
    for window in 3month 6month 1year 2year; do
        if [ -d "results_$window" ]; then
            echo "  $window window:"
            if [ -f "results_$window/lab_result_matrix.csv" ]; then
                rows=$(wc -l < "results_$window/lab_result_matrix.csv")
                cols=$(head -1 "results_$window/lab_result_matrix.csv" | tr ',' '\n' | wc -l)
                echo "    Matrix: ${rows} rows x ${cols} columns"
            fi
            if [ -f "results_$window/summary_statistics.csv" ]; then
                echo "    Summary: $(wc -l < "results_$window/summary_statistics.csv") metrics"
            fi
        fi
    done
    
    echo ""
    echo "Column filtering comparison:"
    for option in keep_digits remove_digits; do
        if [ -d "results_$option" ]; then
            echo "  $option:"
            if [ -f "results_$option/lab_result_matrix.csv" ]; then
                rows=$(wc -l < "results_$option/lab_result_matrix.csv")
                cols=$(head -1 "results_$option/lab_result_matrix.csv" | tr ',' '\n' | wc -l)
                echo "    Matrix: ${rows} rows x ${cols} columns"
            fi
        fi
    done
    
    echo ""
    echo "Batch processing results:"
    for batch in 5 10 15 20; do
        if [ -d "batch_$batch" ]; then
            echo "  Batch $batch:"
            if [ -f "batch_$batch/lab_result_matrix.csv" ]; then
                rows=$(wc -l < "batch_$batch/lab_result_matrix.csv")
                cols=$(head -1 "batch_$batch/lab_result_matrix.csv" | tr ',' '\n' | wc -l)
                echo "    Matrix: ${rows} rows x ${cols} columns"
            fi
        fi
    done
}

# Cleanup function
cleanup() {
    print_header "CLEANUP"
    
    echo "Cleaning up temporary directories..."
    
    # Remove temporary directories
    for dir in results_3month results_6month results_1year results_2year results_keep_digits results_remove_digits batch_5 batch_10 batch_15 batch_20 shared_prepared_data analysis_small analysis_medium analysis_large custom_data custom_prepared custom_results perf_results; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo "  Removed: $dir"
        fi
    done
    
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_header "CLINICAL LAB ANALYSIS PIPELINE - ADVANCED CONFIGURATION EXAMPLES"
    
    echo "This script demonstrates advanced configuration options for the Clinical Lab Analysis Pipeline."
    echo "It will show you how to optimize the pipeline for different use cases and requirements."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    echo ""
    echo "Starting advanced examples..."
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
    
    # Show results
    show_results
    
    echo ""
    print_header "ADVANCED EXAMPLES COMPLETED SUCCESSFULLY"
    print_success "All advanced configuration examples completed successfully!"
    print_success "You now have a comprehensive understanding of the pipeline's capabilities."
    
    echo ""
    echo "Key takeaways:"
    echo "1. Date windows affect the number of lab results matched"
    echo "2. Column filtering can reduce noise in the data"
    echo "3. Batch processing helps manage memory usage"
    echo "4. Memory optimization techniques improve performance"
    echo "5. Custom file names provide flexibility"
    echo "6. Performance monitoring helps optimize settings"
    
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

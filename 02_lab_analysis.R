#!/usr/bin/env Rscript

# =============================================================================
# LAB ANALYSIS SCRIPT
# =============================================================================
# This script performs lab analysis using prepared RDS files from the
# data preparation script.
#
# Usage: Rscript 02_lab_analysis.R [options]
#
# Options:
#   --input_dir PATH          Input directory containing RDS files (required)
#   --n_patients N            Number of patients to process (default: 5, use 'all' for all patients)
#   --output_dir PATH         Output directory for results (default: ./lab_analysis_results)
#   --max_date_diff DAYS      Maximum date difference in days (default: 365)
#   --remove_digit_cols       Remove columns with only digit names (default: TRUE)
#   --help, -h                Show this help message
#
# Examples:
#   # Process first 5 patients (testing)
#   Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients 5
#
#   # Process all patients
#   Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients all
#
#   # Process 100 patients with custom output directory
#   Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients 100 --output_dir ./results
#
#   # Process with custom date difference threshold
#   Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients 10 --max_date_diff 180
#
# =============================================================================

# Load required libraries
suppressPackageStartupMessages({
  library(data.table)
  library(argparse)
})

# =============================================================================
# COMMAND LINE ARGUMENT PARSING
# =============================================================================

create_parser <- function() {
  parser <- ArgumentParser(
    description = "Lab Analysis Script for Clinical Data Pipeline",
    formatter_class = "argparse.RawDescriptionHelpFormatter",
    epilog = "
EXAMPLES:
  # Basic usage - process first 5 patients
  Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients 5
  
  # Process all patients
  Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients all
  
  # Process 100 patients with custom settings
  Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients 100 --max_date_diff 180 --output_dir ./results
  
  # Show help
  Rscript 02_lab_analysis.R --help

INPUT FILES (from data preparation script):
  - cohort.rds: Processed cohort data (required)
  - lab_subset.rds: Lab results subset (required)
  - cancer_subset.rds: Cancer diagnosis subset (optional)

OUTPUT FILES:
  - lab_result_matrix.csv: Wide format matrix with lab results
  - lab_date_matrix.csv: Wide format matrix with lab dates
  - detailed_lab_results.csv: Detailed results with date differences
  - summary_statistics.csv: Analysis summary
  - lab_analysis_summary.txt: Text summary report
  - *.rds: RDS versions of all output files
"
  )
  
  parser$add_argument("--input_dir", 
                     required = TRUE,
                     help = "Input directory containing RDS files from data preparation script")
  
  parser$add_argument("--n_patients", 
                     default = "5",
                     help = "Number of patients to process (default: %(default)s, use 'all' for all patients)")
  
  parser$add_argument("--output_dir", 
                     default = "./lab_analysis_results",
                     help = "Output directory for results (default: %(default)s)")
  
  parser$add_argument("--max_date_diff", 
                     type = "integer",
                     default = 365,
                     help = "Maximum date difference in days (default: %(default)s)")
  
  parser$add_argument("--remove_digit_cols", 
                     action = "store_true",
                     default = TRUE,
                     help = "Remove columns with only digit names (default: %(default)s)")
  
  return(parser)
}

# Parse arguments
args <- create_parser()$parse_args()

# Parse n_patients argument
if (args$n_patients == "all") {
  n_patients <- Inf
} else {
  n_patients <- as.numeric(args$n_patients)
  if (is.na(n_patients) || n_patients <= 0) {
    stop("n_patients must be a positive number or 'all'")
  }
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_stage <- function(stage, message, ...) {
  cat(sprintf("[STAGE %s] %s\n", stage, message), ...)
}

print_progress <- function(current, total, item_name = "items") {
  if (total > 0) {
    percent <- round((current / total) * 100, 1)
    cat(sprintf("Progress: %d/%d %s (%.1f%%)\n", current, total, item_name, percent))
  }
}

# Function to find nearest lab results for each patient and test type
find_nearest_lab_results <- function(patient_mrn, reference_date, test_type = NULL, max_date_diff = 365) {
  # Get all lab results for this patient
  patient_labs <- lab_subset_cohort[DFCI_MRN == patient_mrn]
  
  # If test_type is specified, filter by test type
  if (!is.null(test_type)) {
    patient_labs <- patient_labs[TEST_TYPE_CD == test_type]
  }
  
  if (nrow(patient_labs) == 0) {
    return(data.table(DFCI_MRN = patient_mrn, 
                     TEST_TYPE_CD = test_type,
                     TEXT_RESULT = NA_character_,
                     SPECIMEN_COLLECT_DT = as.Date(NA),
                     DATE_DIFF = NA_real_))
  }
  
  # Calculate date differences
  patient_labs$DATE_DIFF <- abs(as.numeric(patient_labs$SPECIMEN_COLLECT_DT - reference_date))
  
  # Filter by maximum date difference
  patient_labs <- patient_labs[DATE_DIFF <= max_date_diff]
  
  if (nrow(patient_labs) == 0) {
    return(data.table(DFCI_MRN = patient_mrn, 
                     TEST_TYPE_CD = test_type,
                     TEXT_RESULT = NA_character_,
                     SPECIMEN_COLLECT_DT = as.Date(NA),
                     DATE_DIFF = NA_real_))
  }
  
  # Find the row with minimum date difference
  nearest_idx <- which.min(patient_labs$DATE_DIFF)
  
  return(patient_labs[nearest_idx, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, DATE_DIFF)])
}

# =============================================================================
# MAIN LAB ANALYSIS FUNCTION
# =============================================================================

perform_lab_analysis <- function(args, n_patients) {
  start_time <- Sys.time()
  
  cat("=" %R% 80, "\n")
  cat("LAB ANALYSIS SCRIPT\n")
  cat("=" %R% 80, "\n")
  cat("Start time:", format(start_time), "\n")
  cat("Input directory:", args$input_dir, "\n")
  cat("Output directory:", args$output_dir, "\n")
  cat("Number of patients:", ifelse(is.infinite(n_patients), "ALL", n_patients), "\n")
  cat("Max date difference:", args$max_date_diff, "days\n")
  cat("Remove digit columns:", args$remove_digit_cols, "\n\n")
  
  # =============================================================================
  # STAGE 1: LOAD RDS FILES
  # =============================================================================
  print_stage("1", "Loading RDS files...")
  
  # Check if input directory exists
  if (!dir.exists(args$input_dir)) {
    stop("Input directory not found: ", args$input_dir)
  }
  
  # Load RDS files
  cohort_file <- file.path(args$input_dir, "cohort.rds")
  lab_subset_file <- file.path(args$input_dir, "lab_subset.rds")
  cancer_subset_file <- file.path(args$input_dir, "cancer_subset.rds")
  
  if (!file.exists(cohort_file)) {
    stop("Cohort RDS file not found: ", cohort_file)
  }
  if (!file.exists(lab_subset_file)) {
    stop("Lab subset RDS file not found: ", lab_subset_file)
  }
  
  cat("Loading cohort data...\n")
  cohort <- readRDS(cohort_file)
  
  cat("Loading lab subset data...\n")
  lab_subset <- readRDS(lab_subset_file)
  
  # Load cancer data if available (optional)
  if (file.exists(cancer_subset_file)) {
    cat("Loading cancer subset data...\n")
    cancer_subset <- readRDS(cancer_subset_file)
    cat("✓ RDS files loaded successfully\n")
    cat("  - Cohort records:", nrow(cohort), "\n")
    cat("  - Lab subset records:", nrow(lab_subset), "\n")
    cat("  - Cancer subset records:", nrow(cancer_subset), "\n")
  } else {
    cat("No cancer data found, skipping...\n")
    cancer_subset <- data.table()
    cat("✓ RDS files loaded successfully\n")
    cat("  - Cohort records:", nrow(cohort), "\n")
    cat("  - Lab subset records:", nrow(lab_subset), "\n")
    cat("  - Cancer subset records: 0 (not provided)\n")
  }
  
  # =============================================================================
  # STAGE 2: PREPARE DATA FOR ANALYSIS
  # =============================================================================
  print_stage("2", "Preparing data for analysis...")
  
  # Convert dates to proper format
  cohort$REPORT_DT <- as.Date(cohort$REPORT_DT, format = "%d-%b-%y")
  lab_subset$SPECIMEN_COLLECT_DT <- as.Date(lab_subset$SPECIMEN_COLLECT_DT)
  
  # Filter lab_subset to only include patients in cohort
  lab_subset_cohort <- lab_subset[DFCI_MRN %in% cohort$DFCI_MRN]
  
  # Get patients who actually have lab data
  patients_with_lab_data <- unique(lab_subset_cohort$DFCI_MRN)
  cat("Patients in cohort with lab data:", length(patients_with_lab_data), "out of", nrow(cohort), "\n")
  
  # Filter cohort to only include patients with lab data
  cohort_with_lab <- cohort[DFCI_MRN %in% patients_with_lab_data]
  
  # Limit to specified number of patients
  if (is.infinite(n_patients)) {
    cohort_with_lab_test <- cohort_with_lab
    cat("Processing ALL patients with lab data:", nrow(cohort_with_lab_test), "\n")
  } else {
    cohort_with_lab_test <- cohort_with_lab[1:min(n_patients, nrow(cohort_with_lab))]
    cat("Processing first", nrow(cohort_with_lab_test), "patients with lab data\n")
  }
  
  # Get all unique test types in the lab data
  unique_test_types <- unique(lab_subset_cohort$TEST_TYPE_CD)
  cat("Found", length(unique_test_types), "unique test types\n")
  
  cat("✓ Data preparation completed\n")
  
  # =============================================================================
  # STAGE 3: CREATE LAB RESULT MATRICES
  # =============================================================================
  print_stage("3", "Creating lab result matrices...")
  
  # Initialize result lists
  lab_result_matrix <- data.table()
  
  # Process each patient
  total_patients <- nrow(cohort_with_lab_test)
  cat("Starting to process", total_patients, "patients...\n")
  
  for (i in 1:total_patients) {
    patient_mrn <- cohort_with_lab_test$DFCI_MRN[i]
    reference_date <- cohort_with_lab_test$REPORT_DT[i]
    
    # Show progress every 10 patients or at the start
    if (i == 1 || i %% 10 == 0 || i == total_patients) {
      print_progress(i, total_patients, "patients")
      cat("  Current patient MRN:", patient_mrn, "\n")
    }
    
    # Find nearest lab results for each test type
    patient_results <- rbindlist(lapply(unique_test_types, function(test_type) {
      find_nearest_lab_results(patient_mrn, reference_date, test_type, args$max_date_diff)
    }))
    
    # Add to result matrices
    lab_result_matrix <- rbind(lab_result_matrix, patient_results)
  }
  
  cat("✓ Lab result matrices created successfully\n")
  cat("  - Total lab measurements processed:", nrow(lab_result_matrix), "\n")
  
  # =============================================================================
  # STAGE 4: ADD REPORT_DT AND CREATE WIDE FORMAT
  # =============================================================================
  print_stage("4", "Adding REPORT_DT and creating wide format matrices...")
  
  # Add REPORT_DT to lab_result_matrix by merging with cohort data
  lab_result_matrix_with_dates <- merge(lab_result_matrix, 
                                       cohort_with_lab_test[, .(DFCI_MRN, REPORT_DT)], 
                                       by = "DFCI_MRN", all.x = TRUE)
  
  # Reshape to wide format for lab results matrix
  lab_result_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                          value.var = "TEXT_RESULT", fill = NA_character_)
  
  # Reshape to wide format for lab dates matrix
  lab_date_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                        value.var = "SPECIMEN_COLLECT_DT", fill = as.Date(NA))
  
  cat("✓ Wide format matrices created\n")
  cat("  - Lab result matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
  cat("  - Lab date matrix dimensions:", nrow(lab_date_wide), "x", ncol(lab_date_wide), "\n")
  
  # =============================================================================
  # STAGE 5: REMOVE DIGIT-ONLY COLUMNS
  # =============================================================================
  if (args$remove_digit_cols) {
    print_stage("5", "Removing digit-only columns...")
    
    # Get column names that are all digits
    digit_columns <- names(lab_result_wide)[grepl("^[0-9]+$", names(lab_result_wide))]
    
    if (length(digit_columns) > 0) {
      cat("Removing", length(digit_columns), "columns that are all digits\n")
      cat("Sample digit columns:", paste(digit_columns[1:min(10, length(digit_columns))], collapse = ", "), "\n")
      
      # Remove digit-only columns from both matrices
      lab_result_wide <- lab_result_wide[, !digit_columns, with = FALSE]
      lab_date_wide <- lab_date_wide[, !digit_columns, with = FALSE]
      
      cat("✓ Digit-only columns removed\n")
      cat("  - Final lab result matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
      cat("  - Final lab date matrix dimensions:", nrow(lab_date_wide), "x", ncol(lab_date_wide), "\n")
    } else {
      cat("No digit-only columns found\n")
    }
  } else {
    print_stage("5", "Skipping digit-only column removal (disabled)")
  }
  
  # =============================================================================
  # STAGE 6: CREATE OUTPUT DIRECTORY AND SAVE RESULTS
  # =============================================================================
  print_stage("6", "Creating output directory and saving results...")
  
  # Create output directory if it doesn't exist
  if (!dir.exists(args$output_dir)) {
    dir.create(args$output_dir, recursive = TRUE)
    cat("Output directory created:", args$output_dir, "\n")
  }
  
  # Save matrices as CSV
  fwrite(lab_result_wide, file.path(args$output_dir, "lab_result_matrix.csv"))
  fwrite(lab_date_wide, file.path(args$output_dir, "lab_date_matrix.csv"))
  fwrite(lab_result_matrix_with_dates, file.path(args$output_dir, "detailed_lab_results.csv"))
  
  # Save RDS versions for faster loading
  saveRDS(lab_result_wide, file.path(args$output_dir, "lab_result_matrix.rds"))
  saveRDS(lab_date_wide, file.path(args$output_dir, "lab_date_matrix.rds"))
  saveRDS(lab_result_matrix_with_dates, file.path(args$output_dir, "detailed_lab_results.rds"))
  
  cat("✓ Results saved successfully\n")
  cat("  - lab_result_matrix.csv/.rds\n")
  cat("  - lab_date_matrix.csv/.rds\n")
  cat("  - detailed_lab_results.csv/.rds\n")
  
  # =============================================================================
  # STAGE 7: CREATE SUMMARY STATISTICS AND REPORT
  # =============================================================================
  print_stage("7", "Creating summary statistics and report...")
  
  # Calculate summary statistics
  total_measurements <- nrow(lab_result_matrix_with_dates)
  non_na_measurements <- sum(!is.na(lab_result_matrix_with_dates$TEXT_RESULT) & 
                             lab_result_matrix_with_dates$TEXT_RESULT != "")
  
  summary_stats <- data.table(
    Metric = c("Total patients processed", 
               "Unique test types",
               "Total lab measurements",
               "Non-NA lab measurements",
               "Lab result matrix rows",
               "Lab result matrix columns",
               "Max date difference (days)",
               "Digit columns removed",
               "Processing time (minutes)"),
    Value = c(nrow(cohort_with_lab_test),
              length(unique_test_types),
              total_measurements,
              non_na_measurements,
              nrow(lab_result_wide),
              ncol(lab_result_wide),
              args$max_date_diff,
              ifelse(args$remove_digit_cols, length(digit_columns), 0),
              round(as.numeric(Sys.time() - start_time, units = "mins"), 2))
  )
  
  # Save summary statistics
  fwrite(summary_stats, file.path(args$output_dir, "summary_statistics.csv"))
  
  # Create text summary
  summary_text <- paste0(
    "LAB ANALYSIS SUMMARY\n",
    "====================\n",
    "Generated on: ", format(Sys.time()), "\n",
    "Input directory: ", args$input_dir, "\n",
    "Output directory: ", args$output_dir, "\n",
    "Patients processed: ", nrow(cohort_with_lab_test), "\n",
    "Max date difference: ", args$max_date_diff, " days\n\n",
    "RESULTS:\n",
    "- Total lab measurements: ", total_measurements, "\n",
    "- Non-NA lab measurements: ", non_na_measurements, "\n",
    "- Unique test types: ", length(unique_test_types), "\n",
    "- Final matrix dimensions: ", nrow(lab_result_wide), " x ", ncol(lab_result_wide), "\n",
    "- Digit columns removed: ", ifelse(args$remove_digit_cols, length(digit_columns), 0), "\n\n",
    "OUTPUT FILES:\n",
    "- lab_result_matrix.csv/.rds: Wide format lab results\n",
    "- lab_date_matrix.csv/.rds: Wide format lab dates\n",
    "- detailed_lab_results.csv/.rds: Detailed results with date differences\n",
    "- summary_statistics.csv: Analysis summary\n",
    "- lab_analysis_summary.txt: This summary\n\n",
    "SAMPLE DATA:\n",
    "First few rows of lab result matrix:\n"
  )
  
  # Add sample data to summary
  if (nrow(lab_result_wide) > 0) {
    sample_data <- capture.output(print(lab_result_wide[1:min(3, nrow(lab_result_wide)), 1:min(8, ncol(lab_result_wide))]))
    summary_text <- paste0(summary_text, paste(sample_data, collapse = "\n"), "\n")
  }
  
  writeLines(summary_text, file.path(args$output_dir, "lab_analysis_summary.txt"))
  
  cat("✓ Summary report created\n")
  cat("  - summary_statistics.csv\n")
  cat("  - lab_analysis_summary.txt\n")
  
  # =============================================================================
  # STAGE 8: DISPLAY SAMPLE RESULTS
  # =============================================================================
  print_stage("8", "Displaying sample results...")
  
  cat("\n=== SAMPLE LAB RESULT MATRIX (first 3 rows, first 8 columns) ===\n")
  if (nrow(lab_result_wide) > 0) {
    print(lab_result_wide[1:min(3, nrow(lab_result_wide)), 1:min(8, ncol(lab_result_wide))])
  }
  
  cat("\n=== SAMPLE LAB DATE MATRIX (first 3 rows, first 8 columns) ===\n")
  if (nrow(lab_date_wide) > 0) {
    print(lab_date_wide[1:min(3, nrow(lab_date_wide)), 1:min(8, ncol(lab_date_wide))])
  }
  
  # Show some actual TEXT_RESULT values to verify they're correct
  cat("\n=== VERIFICATION: Sample TEXT_RESULT values ===\n")
  if (nrow(lab_result_matrix_with_dates) > 0) {
    sample_results <- lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""][1:min(5, nrow(lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""]))]
    if (nrow(sample_results) > 0) {
      print(sample_results[, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, DATE_DIFF)])
    } else {
      cat("No non-NA TEXT_RESULT values found\n")
    }
  }
  
  # =============================================================================
  # COMPLETION
  # =============================================================================
  end_time <- Sys.time()
  processing_time <- round(as.numeric(end_time - start_time, units = "mins"), 2)
  
  cat("\n", "=" %R% 80, "\n")
  cat("LAB ANALYSIS COMPLETED SUCCESSFULLY\n")
  cat("=" %R% 80, "\n")
  cat("End time:", format(end_time), "\n")
  cat("Total processing time:", processing_time, "minutes\n")
  cat("Output directory:", args$output_dir, "\n")
  cat("Patients processed:", nrow(cohort_with_lab_test), "\n")
  cat("Final matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
  
  return(list(
    lab_result_wide = lab_result_wide,
    lab_date_wide = lab_date_wide,
    lab_result_matrix_with_dates = lab_result_matrix_with_dates,
    summary_stats = summary_stats
  ))
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if (!interactive()) {
  tryCatch({
    result <- perform_lab_analysis(args, n_patients)
    quit(status = 0)
  }, error = function(e) {
    cat("ERROR:", e$message, "\n")
    quit(status = 1)
  })
}

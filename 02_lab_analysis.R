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
  - lab_result_matrix.csv: Wide format matrix with lab results (deduplicated)
  - lab_date_matrix.csv: Wide format matrix with lab dates (deduplicated)
  - detailed_lab_results.csv: Detailed results with date differences (deduplicated)
  - lab_results_long_format.csv: Long format with ALL lab results (including duplicates)
  - lab_result_matrix_with_suffixes.csv: Wide format with MRN suffixes for multiple test types
  - lab_date_matrix_with_suffixes.csv: Wide format dates with MRN suffixes
  - summary_statistics.csv: Analysis summary
  - lab_analysis_summary.txt: Text summary report
  - *.rds: RDS versions of all output files (enables caching)
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

# Function to check if RDS files exist and are newer than input files
check_rds_cache <- function(output_dir, input_files) {
  rds_files <- c(
    "lab_result_matrix.rds",
    "lab_date_matrix.rds", 
    "detailed_lab_results.rds",
    "lab_results_long_format.rds",
    "lab_result_matrix_with_suffixes.rds",
    "lab_date_matrix_with_suffixes.rds"
  )
  
  # Check if all RDS files exist
  rds_paths <- file.path(output_dir, rds_files)
  all_exist <- all(file.exists(rds_paths))
  
  if (!all_exist) {
    return(FALSE)
  }
  
  # Check if RDS files are newer than input files
  rds_mtime <- min(file.mtime(rds_paths))
  input_mtime <- max(file.mtime(input_files))
  
  return(rds_mtime > input_mtime)
}

# Function to load cached results
load_cached_results <- function(output_dir) {
  cat("Loading cached results from RDS files...\n")
  
  result <- list(
    lab_result_wide = readRDS(file.path(output_dir, "lab_result_matrix.rds")),
    lab_date_wide = readRDS(file.path(output_dir, "lab_date_matrix.rds")),
    lab_result_matrix_with_dates = readRDS(file.path(output_dir, "detailed_lab_results.rds")),
    lab_result_long_all = readRDS(file.path(output_dir, "lab_results_long_format.rds")),
    lab_result_wide_suffix = readRDS(file.path(output_dir, "lab_result_matrix_with_suffixes.rds")),
    lab_date_wide_suffix = readRDS(file.path(output_dir, "lab_date_matrix_with_suffixes.rds"))
  )
  
  cat("✓ Cached results loaded successfully\n")
  return(result)
}

# Function to find nearest lab results for each patient and test type
find_nearest_lab_results <- function(patient_mrn, reference_date, lab_subset_cohort, test_type = NULL, max_date_diff = 365) {
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
  
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("LAB ANALYSIS SCRIPT\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
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
      find_nearest_lab_results(patient_mrn, reference_date, lab_subset_cohort, test_type, args$max_date_diff)
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
  # Use allow.cartesian=TRUE to handle potential duplicates
  # This is safe in our case given we're creating multiple rows per patient (one for each test type)
  lab_result_matrix_with_dates <- merge(lab_result_matrix, 
                                       cohort_with_lab_test[, .(DFCI_MRN, REPORT_DT)], 
                                       by = "DFCI_MRN", all.x = TRUE, allow.cartesian = TRUE)
  
  # Debug: Check the data before dcast
  cat("Debug: Sample data before dcast:\n")
  if (nrow(lab_result_matrix_with_dates) > 0) {
    sample_data <- lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""][1:min(5, nrow(lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""]))]
    if (nrow(sample_data) > 0) {
      print(sample_data[, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, REPORT_DT)])
    }
  }
  
  # Check for duplicates before dcast
  duplicates <- lab_result_matrix_with_dates[, .N, by = .(DFCI_MRN, REPORT_DT, TEST_TYPE_CD)][N > 1]
  if (nrow(duplicates) > 0) {
    cat("Warning: Found", nrow(duplicates), "duplicate combinations of [DFCI_MRN, REPORT_DT, TEST_TYPE_CD]\n")
    cat("Sample duplicates:\n")
    print(duplicates[1:min(5, nrow(duplicates))])
    
    # For duplicates, we'll take the one with the smallest DATE_DIFF (closest to reference date)
    # This ensures we get the most relevant lab result for each combination
    lab_result_matrix_with_dates <- lab_result_matrix_with_dates[lab_result_matrix_with_dates[, .I[which.min(DATE_DIFF)], by = .(DFCI_MRN, REPORT_DT, TEST_TYPE_CD)]$V1]
    cat("Removed duplicates (kept closest by date), remaining records:", nrow(lab_result_matrix_with_dates), "\n")
  }
  
  # Reshape to wide format for lab results matrix
  # Now we can safely use dcast without aggregation since we've removed duplicates
  lab_result_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                          value.var = "TEXT_RESULT", fill = NA_character_)
  
  # Reshape to wide format for lab dates matrix
  lab_date_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                        value.var = "SPECIMEN_COLLECT_DT", fill = as.Date(NA))
  
  cat("✓ Wide format matrices created\n")
  cat("  - Lab result matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
  cat("  - Lab date matrix dimensions:", nrow(lab_date_wide), "x", ncol(lab_date_wide), "\n")
  
  # Debug: Check the wide format data
  cat("Debug: Sample wide format data:\n")
  if (nrow(lab_result_wide) > 0) {
    print(lab_result_wide[1:min(3, nrow(lab_result_wide)), 1:min(8, ncol(lab_result_wide))])
  }
  
  # Debug: Check for any remaining numeric values that might indicate counting instead of TEXT_RESULT
  cat("Debug: Checking for numeric values in lab result matrix (should be TEXT_RESULT values, not counts):\n")
  if (nrow(lab_result_wide) > 0) {
    # Check a few columns for numeric values
    sample_cols <- names(lab_result_wide)[3:min(8, ncol(lab_result_wide))]
    for (col in sample_cols) {
      if (is.character(lab_result_wide[[col]])) {
        numeric_vals <- lab_result_wide[!is.na(get(col)) & get(col) != "" & grepl("^[0-9]+$", get(col)), .N]
        if (numeric_vals > 0) {
          cat("  Column", col, "has", numeric_vals, "purely numeric values (might be counts):\n")
          sample_vals <- lab_result_wide[!is.na(get(col)) & get(col) != "" & grepl("^[0-9]+$", get(col)), get(col)][1:min(5, numeric_vals)]
          cat("    Sample values:", paste(sample_vals, collapse = ", "), "\n")
        }
      }
    }
  }
  
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
  
  # =============================================================================
  # STAGE 5.5: CHECK FOR CACHED RESULTS
  # =============================================================================
  print_stage("5.5", "Checking for cached results...")
  
  input_files <- c(cohort_file, lab_subset_file)
  if (file.exists(cancer_subset_file)) {
    input_files <- c(input_files, cancer_subset_file)
  }
  
  if (check_rds_cache(args$output_dir, input_files)) {
    cat("✓ Found cached results that are newer than input files\n")
    cat("Loading cached results to avoid reprocessing...\n")
    
    # Load cached results
    cached_results <- load_cached_results(args$output_dir)
    
    # Display cached results summary
    cat("\n=== CACHED RESULTS SUMMARY ===\n")
    cat("Lab result matrix dimensions:", nrow(cached_results$lab_result_wide), "x", ncol(cached_results$lab_result_wide), "\n")
    cat("Lab date matrix dimensions:", nrow(cached_results$lab_date_wide), "x", ncol(cached_results$lab_date_wide), "\n")
    cat("Detailed lab results records:", nrow(cached_results$lab_result_matrix_with_dates), "\n")
    cat("Long format records:", nrow(cached_results$lab_result_long_all), "\n")
    cat("Lab result matrix with suffixes dimensions:", nrow(cached_results$lab_result_wide_suffix), "x", ncol(cached_results$lab_result_wide_suffix), "\n")
    cat("Lab date matrix with suffixes dimensions:", nrow(cached_results$lab_date_wide_suffix), "x", ncol(cached_results$lab_date_wide_suffix), "\n")
    
    # Return cached results
    return(cached_results)
  } else {
    cat("No valid cached results found, proceeding with full analysis...\n")
  }
  
  # =============================================================================
  # STAGE 6.1: CREATE LONG FORMAT FILE WITH ALL LAB RESULTS (INCLUDING DUPLICATES)
  # =============================================================================
  print_stage("6.1", "Creating long format file with all lab results...")
  
  # Create long format with ALL lab results (no duplicate removal)
  # This includes all lab results for each patient, even if they have multiple tests of the same type
  lab_result_long_all <- data.table()
  
  for (i in 1:total_patients) {
    patient_mrn <- cohort_with_lab_test$DFCI_MRN[i]
    reference_date <- cohort_with_lab_test$REPORT_DT[i]
    
    # Get ALL lab results for this patient (not just the nearest)
    patient_all_labs <- lab_subset_cohort[DFCI_MRN == patient_mrn]
    
    if (nrow(patient_all_labs) > 0) {
      # Calculate date differences for all results
      patient_all_labs$DATE_DIFF <- abs(as.numeric(patient_all_labs$SPECIMEN_COLLECT_DT - reference_date))
      
      # Filter by maximum date difference
      patient_all_labs <- patient_all_labs[DATE_DIFF <= args$max_date_diff]
      
      # Add REPORT_DT
      patient_all_labs$REPORT_DT <- reference_date
      
      # Select relevant columns
      patient_all_labs_selected <- patient_all_labs[, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, DATE_DIFF, REPORT_DT)]
      
      # Add to long format results
      lab_result_long_all <- rbind(lab_result_long_all, patient_all_labs_selected)
    }
  }
  
  # Sort by MRN, TEST_TYPE_CD, and DATE_DIFF
  lab_result_long_all <- lab_result_long_all[order(DFCI_MRN, TEST_TYPE_CD, DATE_DIFF)]
  
  cat("✓ Long format file created with all lab results\n")
  cat("  - Total records:", nrow(lab_result_long_all), "\n")
  cat("  - Unique patients:", length(unique(lab_result_long_all$DFCI_MRN)), "\n")
  cat("  - Unique test types:", length(unique(lab_result_long_all$TEST_TYPE_CD)), "\n")
  
  # =============================================================================
  # STAGE 6.2: CREATE DETAILED MATRIX WITH MRN SUFFIXES
  # =============================================================================
  print_stage("6.2", "Creating detailed matrix with MRN suffixes...")
  
  # Create a version where each MRN + TEST_TYPE combination gets a unique identifier
  # This handles cases where the same patient has multiple test types
  lab_result_matrix_with_suffixes <- copy(lab_result_matrix_with_dates)
  
  # Add a suffix counter for each MRN + TEST_TYPE combination
  lab_result_matrix_with_suffixes[, SUFFIX_COUNTER := 1:.N, by = .(DFCI_MRN, TEST_TYPE_CD)]
  
  # Create unique MRN identifiers with suffixes
  lab_result_matrix_with_suffixes[, UNIQUE_MRN := paste0(DFCI_MRN, "_", SUFFIX_COUNTER)]
  
  # Create wide format matrices with unique MRN identifiers
  lab_result_wide_suffix <- dcast(lab_result_matrix_with_suffixes, UNIQUE_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                                 value.var = "TEXT_RESULT", fill = NA_character_)
  
  lab_date_wide_suffix <- dcast(lab_result_matrix_with_suffixes, UNIQUE_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                               value.var = "SPECIMEN_COLLECT_DT", fill = as.Date(NA))
  
  # Add original MRN column for reference
  lab_result_wide_suffix[, ORIGINAL_MRN := gsub("_[0-9]+$", "", UNIQUE_MRN)]
  lab_date_wide_suffix[, ORIGINAL_MRN := gsub("_[0-9]+$", "", UNIQUE_MRN)]
  
  # Reorder columns to put ORIGINAL_MRN first
  setcolorder(lab_result_wide_suffix, c("ORIGINAL_MRN", "UNIQUE_MRN", "REPORT_DT"))
  setcolorder(lab_date_wide_suffix, c("ORIGINAL_MRN", "UNIQUE_MRN", "REPORT_DT"))
  
  cat("✓ Detailed matrix with MRN suffixes created\n")
  cat("  - Lab result matrix with suffixes dimensions:", nrow(lab_result_wide_suffix), "x", ncol(lab_result_wide_suffix), "\n")
  cat("  - Lab date matrix with suffixes dimensions:", nrow(lab_date_wide_suffix), "x", ncol(lab_date_wide_suffix), "\n")
  
  # =============================================================================
  # STAGE 6.3: SAVE ALL RESULTS
  # =============================================================================
  print_stage("6.3", "Saving all results...")
  
  # Save matrices as CSV
  fwrite(lab_result_wide, file.path(args$output_dir, "lab_result_matrix.csv"))
  fwrite(lab_date_wide, file.path(args$output_dir, "lab_date_matrix.csv"))
  fwrite(lab_result_matrix_with_dates, file.path(args$output_dir, "detailed_lab_results.csv"))
  fwrite(lab_result_long_all, file.path(args$output_dir, "lab_results_long_format.csv"))
  fwrite(lab_result_wide_suffix, file.path(args$output_dir, "lab_result_matrix_with_suffixes.csv"))
  fwrite(lab_date_wide_suffix, file.path(args$output_dir, "lab_date_matrix_with_suffixes.csv"))
  
  # Save RDS versions for faster loading
  saveRDS(lab_result_wide, file.path(args$output_dir, "lab_result_matrix.rds"))
  saveRDS(lab_date_wide, file.path(args$output_dir, "lab_date_matrix.rds"))
  saveRDS(lab_result_matrix_with_dates, file.path(args$output_dir, "detailed_lab_results.rds"))
  saveRDS(lab_result_long_all, file.path(args$output_dir, "lab_results_long_format.rds"))
  saveRDS(lab_result_wide_suffix, file.path(args$output_dir, "lab_result_matrix_with_suffixes.rds"))
  saveRDS(lab_date_wide_suffix, file.path(args$output_dir, "lab_date_matrix_with_suffixes.rds"))
  
  cat("✓ Results saved successfully\n")
  cat("  - lab_result_matrix.csv/.rds\n")
  cat("  - lab_date_matrix.csv/.rds\n")
  cat("  - detailed_lab_results.csv/.rds\n")
  cat("  - lab_results_long_format.csv/.rds\n")
  cat("  - lab_result_matrix_with_suffixes.csv/.rds\n")
  cat("  - lab_date_matrix_with_suffixes.csv/.rds\n")
  
  # =============================================================================
  # STAGE 7: CREATE SUMMARY STATISTICS AND REPORT
  # =============================================================================
  print_stage("7", "Creating summary statistics and report...")
  
  # Calculate summary statistics
  total_measurements <- nrow(lab_result_matrix_with_dates)
  non_na_measurements <- sum(!is.na(lab_result_matrix_with_dates$TEXT_RESULT) & 
                             lab_result_matrix_with_dates$TEXT_RESULT != "")
  total_long_measurements <- nrow(lab_result_long_all)
  non_na_long_measurements <- sum(!is.na(lab_result_long_all$TEXT_RESULT) & 
                                  lab_result_long_all$TEXT_RESULT != "")
  
  summary_stats <- data.table(
    Metric = c("Total patients processed", 
               "Unique test types",
               "Total lab measurements (deduplicated)",
               "Non-NA lab measurements (deduplicated)",
               "Total lab measurements (all, including duplicates)",
               "Non-NA lab measurements (all, including duplicates)",
               "Lab result matrix rows",
               "Lab result matrix columns",
               "Lab result matrix with suffixes rows",
               "Lab result matrix with suffixes columns",
               "Max date difference (days)",
               "Digit columns removed",
               "Processing time (minutes)"),
    Value = c(nrow(cohort_with_lab_test),
              length(unique_test_types),
              total_measurements,
              non_na_measurements,
              total_long_measurements,
              non_na_long_measurements,
              nrow(lab_result_wide),
              ncol(lab_result_wide),
              nrow(lab_result_wide_suffix),
              ncol(lab_result_wide_suffix),
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
    "- Total lab measurements (deduplicated): ", total_measurements, "\n",
    "- Non-NA lab measurements (deduplicated): ", non_na_measurements, "\n",
    "- Total lab measurements (all, including duplicates): ", total_long_measurements, "\n",
    "- Non-NA lab measurements (all, including duplicates): ", non_na_long_measurements, "\n",
    "- Unique test types: ", length(unique_test_types), "\n",
    "- Final matrix dimensions: ", nrow(lab_result_wide), " x ", ncol(lab_result_wide), "\n",
    "- Matrix with suffixes dimensions: ", nrow(lab_result_wide_suffix), " x ", ncol(lab_result_wide_suffix), "\n",
    "- Digit columns removed: ", ifelse(args$remove_digit_cols, length(digit_columns), 0), "\n\n",
    "OUTPUT FILES:\n",
    "- lab_result_matrix.csv/.rds: Wide format lab results (deduplicated)\n",
    "- lab_date_matrix.csv/.rds: Wide format lab dates (deduplicated)\n",
    "- detailed_lab_results.csv/.rds: Detailed results with date differences (deduplicated)\n",
    "- lab_results_long_format.csv/.rds: Long format with ALL lab results (including duplicates)\n",
    "- lab_result_matrix_with_suffixes.csv/.rds: Wide format with MRN suffixes for multiple test types\n",
    "- lab_date_matrix_with_suffixes.csv/.rds: Wide format dates with MRN suffixes\n",
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
  
  cat("\n", paste(rep("=", 80), collapse = ""), "\n")
  cat("LAB ANALYSIS COMPLETED SUCCESSFULLY\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("End time:", format(end_time), "\n")
  cat("Total processing time:", processing_time, "minutes\n")
  cat("Output directory:", args$output_dir, "\n")
  cat("Patients processed:", nrow(cohort_with_lab_test), "\n")
  cat("Final matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
  
  return(list(
    lab_result_wide = lab_result_wide,
    lab_date_wide = lab_date_wide,
    lab_result_matrix_with_dates = lab_result_matrix_with_dates,
    lab_result_long_all = lab_result_long_all,
    lab_result_wide_suffix = lab_result_wide_suffix,
    lab_date_wide_suffix = lab_date_wide_suffix,
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

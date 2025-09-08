#!/usr/bin/env Rscript

# =============================================================================
# DATA PREPARATION SCRIPT
# =============================================================================
# This script prepares and processes raw data files, creating RDS files
# for use in the lab analysis script.
#
# Usage: Rscript 01_data_preparation.R [options]
#
# Options:
#   --cohort_file PATH        Path to cohort file (default: cohortmrn_merge.data.csv)
#   --lab_file PATH           Path to lab results file (default: OUTPT_LAB_RESULTS_LABS.csv)
#   --cancer_file PATH        Path to cancer diagnosis file (default: CANCER_DIAGNOSIS_CAREG.csv)
#   --input_dir PATH          Input directory containing data files
#   --output_dir PATH         Output directory for RDS files
#   --help, -h                Show this help message
#
# Example:
#   Rscript 01_data_preparation.R --input_dir /path/to/data --output_dir /path/to/output
#   Rscript 01_data_preparation.R --cohort_file my_cohort.csv --output_dir ./results
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
    description = "Data Preparation Script for Lab Analysis Pipeline",
    formatter_class = "argparse.RawDescriptionHelpFormatter",
    epilog = "
EXAMPLES:
  # Basic usage with default file names
  Rscript 01_data_preparation.R --input_dir /data/input --output_dir /data/output
  
  # Custom file names
  Rscript 01_data_preparation.R --cohort_file my_cohort.csv --lab_file my_labs.csv --output_dir ./results
  
  # Show help
  Rscript 01_data_preparation.R --help

OUTPUT FILES:
  - cohort.rds: Processed cohort data
  - lab_subset.rds: Subset of lab results with relevant columns
  - cancer_subset.rds: Subset of cancer diagnosis data
  - lab_results.rds: Full lab results data
  - cancer_diag.rds: Full cancer diagnosis data
  - data_preparation_summary.txt: Summary of data processing
"
  )
  
  parser$add_argument("--cohort_file", 
                     default = "cohortmrn_merge.data.csv",
                     help = "Path to cohort file (default: %(default)s)")
  
  parser$add_argument("--lab_file", 
                     default = "OUTPT_LAB_RESULTS_LABS.csv",
                     help = "Path to lab results file (default: %(default)s)")
  
  parser$add_argument("--cancer_file", 
                     default = "CANCER_DIAGNOSIS_CAREG.csv",
                     help = "Path to cancer diagnosis file (default: %(default)s)")
  
  parser$add_argument("--input_dir", 
                     default = getwd(),
                     help = "Input directory containing data files (default: current directory)")
  
  parser$add_argument("--output_dir", 
                     default = "./prepared_data",
                     help = "Output directory for RDS files (default: %(default)s)")
  
  return(parser)
}

# Parse arguments
args <- create_parser()$parse_args()

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

# =============================================================================
# MAIN DATA PREPARATION FUNCTION
# =============================================================================

prepare_data <- function(args) {
  start_time <- Sys.time()
  
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("DATA PREPARATION SCRIPT\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("Start time:", format(start_time), "\n")
  cat("Input directory:", args$input_dir, "\n")
  cat("Output directory:", args$output_dir, "\n\n")
  
  # Create output directory if it doesn't exist
  if (!dir.exists(args$output_dir)) {
    print_stage("1", "Creating output directory...")
    dir.create(args$output_dir, recursive = TRUE)
    cat("✓ Output directory created:", args$output_dir, "\n")
  }
  
  # =============================================================================
  # STAGE 1: READ AND PROCESS COHORT DATA
  # =============================================================================
  print_stage("1", "Reading and processing cohort data...")
  
  cohort_file_path <- file.path(args$input_dir, args$cohort_file)
  if (!file.exists(cohort_file_path)) {
    stop("Cohort file not found: ", cohort_file_path)
  }
  
  cat("Reading cohort file:", cohort_file_path, "\n")
  cohort <- fread(cohort_file_path, sep = ",")
  cohort_idmrns <- unique(cohort$DFCI_MRN)
  total_cohort <- length(cohort_idmrns)
  
  cat("✓ Cohort data loaded successfully\n")
  cat("  - Total records:", nrow(cohort), "\n")
  cat("  - Unique patients:", total_cohort, "\n")
  
  # =============================================================================
  # STAGE 2: READ AND PROCESS LAB RESULTS
  # =============================================================================
  print_stage("2", "Reading and processing lab results...")
  
  lab_file_path <- file.path(args$input_dir, args$lab_file)
  if (!file.exists(lab_file_path)) {
    stop("Lab results file not found: ", lab_file_path)
  }
  
  cat("Reading lab results file:", lab_file_path, "\n")
  lab_results <- fread(lab_file_path, sep = ",")
  
  # Create subset with relevant columns
  lab_subset <- lab_results[, c("DFCI_MRN", "SPECIMEN_COLLECT_DT", "TEST_TYPE_CD", "TEST_TYPE_DESCR", "TEXT_RESULT")]
  lab_idmrns <- unique(lab_subset$DFCI_MRN)
  
  cat("✓ Lab results processed successfully\n")
  cat("  - Total lab records:", nrow(lab_results), "\n")
  cat("  - Lab subset records:", nrow(lab_subset), "\n")
  cat("  - Unique patients with lab data:", length(lab_idmrns), "\n")
  
  # =============================================================================
  # STAGE 3: READ AND PROCESS CANCER DIAGNOSIS DATA
  # =============================================================================
  print_stage("3", "Reading and processing cancer diagnosis data...")
  
  cancer_file_path <- file.path(args$input_dir, args$cancer_file)
  if (!file.exists(cancer_file_path)) {
    stop("Cancer diagnosis file not found: ", cancer_file_path)
  }
  
  cat("Reading cancer diagnosis file:", cancer_file_path, "\n")
  cancer_diag <- fread(cancer_file_path, sep = ",")
  
  # Create subset with relevant columns
  cancer_subset <- cancer_diag[, c("DFCI_MRN", "SITE_DESCR", "HISTOLOGY_DESCR", "GRADE_DIFF_DESC", "DATE_FIRST_BIOPSY", "SSDI_KI_67", "SURVIVAL_AFTER_DIAGNOSIS_NBR")]
  cancer_idmrns <- unique(cancer_subset$DFCI_MRN)
  
  cat("✓ Cancer diagnosis data processed successfully\n")
  cat("  - Total cancer records:", nrow(cancer_diag), "\n")
  cat("  - Cancer subset records:", nrow(cancer_subset), "\n")
  cat("  - Unique patients with cancer data:", length(cancer_idmrns), "\n")
  
  # =============================================================================
  # STAGE 4: CALCULATE OVERLAPS AND STATISTICS
  # =============================================================================
  print_stage("4", "Calculating overlaps and statistics...")
  
  # Find overlaps
  lab_overlap <- intersect(cohort_idmrns, lab_idmrns)
  cancer_overlap <- intersect(cohort_idmrns, cancer_idmrns)
  
  # Calculate counts and percentages
  lab_count <- length(lab_overlap)
  lab_percent <- round((lab_count / total_cohort) * 100, 2)
  
  cancer_count <- length(cancer_overlap)
  cancer_percent <- round((cancer_count / total_cohort) * 100, 2)
  
  cat("✓ Overlap analysis completed\n")
  cat("  - Lab results overlap:", lab_count, "patients (", lab_percent, "%)\n")
  cat("  - Cancer diagnosis overlap:", cancer_count, "patients (", cancer_percent, "%)\n")
  
  # =============================================================================
  # STAGE 5: SAVE RDS FILES
  # =============================================================================
  print_stage("5", "Saving RDS files...")
  
  # Save all data as RDS files
  saveRDS(cohort, file.path(args$output_dir, "cohort.rds"))
  saveRDS(lab_results, file.path(args$output_dir, "lab_results.rds"))
  saveRDS(lab_subset, file.path(args$output_dir, "lab_subset.rds"))
  saveRDS(cancer_diag, file.path(args$output_dir, "cancer_diag.rds"))
  saveRDS(cancer_subset, file.path(args$output_dir, "cancer_subset.rds"))
  
  cat("✓ RDS files saved successfully\n")
  cat("  - cohort.rds\n")
  cat("  - lab_results.rds\n")
  cat("  - lab_subset.rds\n")
  cat("  - cancer_diag.rds\n")
  cat("  - cancer_subset.rds\n")
  
  # =============================================================================
  # STAGE 6: CREATE SUMMARY REPORT
  # =============================================================================
  print_stage("6", "Creating summary report...")
  
  # Create summary statistics
  summary_stats <- data.table(
    Metric = c("Total patients in cohort", 
               "Patients with lab data", 
               "Patients with cancer data",
               "Lab data overlap percentage",
               "Cancer data overlap percentage",
               "Total lab records",
               "Total cancer records",
               "Unique test types",
               "Processing time (minutes)"),
    Value = c(total_cohort,
              lab_count,
              cancer_count,
              paste0(lab_percent, "%"),
              paste0(cancer_percent, "%"),
              nrow(lab_results),
              nrow(cancer_diag),
              length(unique(lab_subset$TEST_TYPE_CD)),
              round(as.numeric(Sys.time() - start_time, units = "mins"), 2))
  )
  
  # Save summary statistics
  fwrite(summary_stats, file.path(args$output_dir, "data_preparation_summary.csv"))
  
  # Create text summary
  summary_text <- paste0(
    "DATA PREPARATION SUMMARY\n",
    "========================\n",
    "Generated on: ", format(Sys.time()), "\n",
    "Input directory: ", args$input_dir, "\n",
    "Output directory: ", args$output_dir, "\n\n",
    "DATA STATISTICS:\n",
    "- Total patients in cohort: ", total_cohort, "\n",
    "- Patients with lab data: ", lab_count, " (", lab_percent, "%)\n",
    "- Patients with cancer data: ", cancer_count, " (", cancer_percent, "%)\n",
    "- Total lab records: ", nrow(lab_results), "\n",
    "- Total cancer records: ", nrow(cancer_diag), "\n",
    "- Unique test types: ", length(unique(lab_subset$TEST_TYPE_CD)), "\n\n",
    "OUTPUT FILES:\n",
    "- cohort.rds: Processed cohort data\n",
    "- lab_subset.rds: Lab results subset\n",
    "- cancer_subset.rds: Cancer diagnosis subset\n",
    "- lab_results.rds: Full lab results\n",
    "- cancer_diag.rds: Full cancer diagnosis\n",
    "- data_preparation_summary.csv: Detailed statistics\n\n",
    "NEXT STEPS:\n",
    "Run the lab analysis script:\n",
    "Rscript 02_lab_analysis.R --input_dir ", args$output_dir, " --n_patients 5\n"
  )
  
  writeLines(summary_text, file.path(args$output_dir, "data_preparation_summary.txt"))
  
  cat("✓ Summary report created\n")
  cat("  - data_preparation_summary.csv\n")
  cat("  - data_preparation_summary.txt\n")
  
  # =============================================================================
  # COMPLETION
  # =============================================================================
  end_time <- Sys.time()
  processing_time <- round(as.numeric(end_time - start_time, units = "mins"), 2)
  
  cat("\n", paste(rep("=", 80), collapse = ""), "\n")
  cat("DATA PREPARATION COMPLETED SUCCESSFULLY\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("End time:", format(end_time), "\n")
  cat("Total processing time:", processing_time, "minutes\n")
  cat("Output directory:", args$output_dir, "\n")
  cat("\nNext step: Run lab analysis script with prepared data\n")
  cat("Example: Rscript 02_lab_analysis.R --input_dir", args$output_dir, "--n_patients 5\n")
  
  return(list(
    cohort = cohort,
    lab_subset = lab_subset,
    cancer_subset = cancer_subset,
    summary_stats = summary_stats
  ))
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

if (!interactive()) {
  tryCatch({
    result <- prepare_data(args)
    quit(status = 0)
  }, error = function(e) {
    cat("ERROR:", e$message, "\n")
    quit(status = 1)
  })
}

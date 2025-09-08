#Library load
library(data.table)

file_dir <- getwd()  # or specify your input directory
save_dir <- "/data/baca/users/sc1238/datasets/projects/for_razane/profile_access/test_data"

# Read main cohort file
file_dir <-  "/data/baca/users/sc1238/datasets/projects/for_razane/profile_access/test_data"

cohort <-fread(file.path(file_dir, "cohortmrn_merge.data.csv"), sep=",")
cohort_idmrns <- unique(cohort$DFCI_MRN)
total_cohort <- length(cohort_idmrns)

# Read and subset lab results file
file_dir <- "/data/gusev/PROFILE/CLINICAL/OncDRS/ALL_2025_03/"
lab_results <- fread(file.path(file_dir, "OUTPT_LAB_RESULTS_LABS.csv"), sep=",")
lab_subset <- lab_results[, c("DFCI_MRN", "SPECIMEN_COLLECT_DT", "TEST_TYPE_CD", "TEST_TYPE_DESCR", "TEXT_RESULT")]
lab_idmrns <- unique(lab_subset$DFCI_MRN)

# Save lab results as RDS
saveRDS(lab_results, file.path(save_dir, "lab_results.rds"))
saveRDS(lab_subset, file.path(save_dir, "lab_subset.rds"))
print("done")

# To load RDS files for analysis later:
lab_subset <- readRDS("/data/baca/users/sc1238/datasets/projects/for_razane/profile_access/test_data/lab_subset.rds")
lab_idmrns <- unique(lab_subset$DFCI_MRN)

# Read and subset cancer diagnosis file
cancer_diag <- fread(file.path(file_dir, "CANCER_DIAGNOSIS_CAREG.csv"), sep=",")
cancer_subset <- cancer_diag[, c("DFCI_MRN", "SITE_DESCR", "HISTOLOGY_DESCR", "GRADE_DIFF_DESC", "DATE_FIRST_BIOPSY", "SSDI_KI_67", "SURVIVAL_AFTER_DIAGNOSIS_NBR")]
cancer_idmrns <- unique(cancer_subset$DFCI_MRN)

# Save cancer diagnosis as RDS
saveRDS(cancer_diag, file.path(save_dir, "cancer_diag.rds"))
saveRDS(cancer_subset, file.path(save_dir, "cancer_subset.rds"))
print("done")

# To load RDS files for analysis later:
cancer_subset <- readRDS("/data/baca/users/sc1238/datasets/projects/for_razane/profile_access/test_data/cancer_subset.rds")
cancer_idmrns <- unique(cancer_subset$DFCI_MRN)


# Find overlaps
lab_overlap <- intersect(cohort_idmrns, lab_idmrns)
cancer_overlap <- intersect(cohort_idmrns, cancer_idmrns)

# Calculate counts and percentages
lab_count <- length(lab_overlap)
lab_percent <- round((lab_count / total_cohort) * 100, 2)

cancer_count <- length(cancer_overlap)
cancer_percent <- round((cancer_count / total_cohort) * 100, 2)

# Results
cat("Total cohort DFCI_MRNs:", total_cohort, "\n")
cat("Lab results overlap:", lab_count, "(", lab_percent, "%)\n")
cat("Cancer diagnosis overlap:", cancer_count, "(", cancer_percent, "%)\n")

# =============================================================================
# DATE MATCHING AND MATRIX CREATION
# =============================================================================

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
cat("Processing", nrow(cohort_with_lab), "patients who have lab data\n")

# Create function to find nearest date for each patient and test type
find_nearest_lab_results <- function(patient_mrn, reference_date, test_type = NULL) {
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
  
  # Find the row with minimum date difference
  nearest_idx <- which.min(patient_labs$DATE_DIFF)
  
  return(patient_labs[nearest_idx, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, DATE_DIFF)])
}

# Get all unique test types in the lab data
unique_test_types <- unique(lab_subset_cohort$TEST_TYPE_CD)
cat("Found", length(unique_test_types), "unique test types\n")

# Create matrices for each patient and test type combination
cat("Creating lab result matrices...\n")

# Initialize result lists
lab_result_matrix <- data.table()
lab_date_matrix <- data.table()

# Process each patient in cohort (only those with lab data) - LIMIT TO FIRST 5 PATIENTS FOR TESTING
cat("Starting to process first 5 patients with lab data for testing...\n")
cohort_with_lab_test <- cohort_with_lab[1:min(5, nrow(cohort_with_lab))]

for (i in 1:nrow(cohort_with_lab_test)) {
  patient_mrn <- cohort_with_lab_test$DFCI_MRN[i]
  reference_date <- cohort_with_lab_test$REPORT_DT[i]
  
  # Show progress
  cat("Processing patient", i, "of", nrow(cohort_with_lab_test), "- MRN:", patient_mrn, "\n")
  
  # Find nearest lab results for each test type
  patient_results <- rbindlist(lapply(unique_test_types, function(test_type) {
    find_nearest_lab_results(patient_mrn, reference_date, test_type)
  }))
  
  # Add to result matrices
  lab_result_matrix <- rbind(lab_result_matrix, patient_results)
}

# Add REPORT_DT to lab_result_matrix by merging with cohort data
lab_result_matrix_with_dates <- merge(lab_result_matrix, 
                                     cohort_with_lab_test[, .(DFCI_MRN, REPORT_DT)], 
                                     by = "DFCI_MRN", all.x = TRUE)

# Reshape to wide format for lab results matrix - FIXED to use actual TEXT_RESULT values
lab_result_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                        value.var = "TEXT_RESULT", fill = NA_character_)

# Reshape to wide format for lab dates matrix - FIXED to use actual SPECIMEN_COLLECT_DT values
lab_date_wide <- dcast(lab_result_matrix_with_dates, DFCI_MRN + REPORT_DT ~ TEST_TYPE_CD, 
                      value.var = "SPECIMEN_COLLECT_DT", fill = as.Date(NA))

# Remove columns that are all digits only (numeric test codes)
# Get column names that are all digits
digit_columns <- names(lab_result_wide)[grepl("^[0-9]+$", names(lab_result_wide))]
cat("Removing", length(digit_columns), "columns that are all digits:", paste(digit_columns[1:min(10, length(digit_columns))], collapse = ", "), "\n")

# Remove digit-only columns from both matrices
if(length(digit_columns) > 0) {
  lab_result_wide <- lab_result_wide[, !digit_columns, with = FALSE]
  lab_date_wide <- lab_date_wide[, !digit_columns, with = FALSE]
}

# Create summary statistics
summary_stats <- data.table(
  Metric = c("Total patients in cohort", 
             "Patients with lab data", 
             "Patients processed (with lab data) - TESTING FIRST 5",
             "Unique test types",
             "Total lab measurements",
             "Average lab measurements per patient",
             "Columns removed (digit-only)",
             "Final lab result matrix columns"),
  Value = c(nrow(cohort),
            length(unique(lab_subset_cohort$DFCI_MRN)),
            nrow(cohort_with_lab_test),
            length(unique_test_types),
            nrow(lab_subset_cohort),
            round(nrow(lab_subset_cohort) / length(unique(lab_subset_cohort$DFCI_MRN)), 2),
            length(digit_columns),
            ncol(lab_result_wide))
)

# Create subdirectory for results
results_dir <- file.path(save_dir, "lab_analysis_results")
if (!dir.exists(results_dir)) {
  dir.create(results_dir, recursive = TRUE)
}

# Save matrices
fwrite(lab_result_wide, file.path(results_dir, "lab_result_matrix.csv"))
fwrite(lab_date_wide, file.path(results_dir, "lab_date_matrix.csv"))
fwrite(summary_stats, file.path(results_dir, "summary_statistics.csv"))

# Save detailed results
fwrite(lab_result_matrix_with_dates, file.path(results_dir, "detailed_lab_results.csv"))

# Save RDS versions for faster loading
saveRDS(lab_result_wide, file.path(results_dir, "lab_result_matrix.rds"))
saveRDS(lab_date_wide, file.path(results_dir, "lab_date_matrix.rds"))
saveRDS(lab_result_matrix_with_dates, file.path(results_dir, "detailed_lab_results.rds"))

# Print summary
cat("\n=== LAB ANALYSIS SUMMARY ===\n")
print(summary_stats)
cat("\nLab result matrix dimensions:", nrow(lab_result_wide), "x", ncol(lab_result_wide), "\n")
cat("Lab date matrix dimensions:", nrow(lab_date_wide), "x", ncol(lab_date_wide), "\n")
cat("Results saved to:", results_dir, "\n")

# Show sample of results
cat("\n=== SAMPLE LAB RESULT MATRIX (first 5 rows, first 10 columns) ===\n")
print(lab_result_wide[1:min(5, nrow(lab_result_wide)), 1:min(11, ncol(lab_result_wide))])

cat("\n=== SAMPLE LAB DATE MATRIX (first 5 rows, first 10 columns) ===\n")
print(lab_date_wide[1:min(5, nrow(lab_date_wide)), 1:min(11, ncol(lab_date_wide))])

# Show some actual TEXT_RESULT values to verify they're correct
cat("\n=== VERIFICATION: Sample TEXT_RESULT values ===\n")
if(nrow(lab_result_matrix_with_dates) > 0) {
  sample_results <- lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""][1:min(10, nrow(lab_result_matrix_with_dates[!is.na(TEXT_RESULT) & TEXT_RESULT != ""]))]
  print(sample_results[, .(DFCI_MRN, TEST_TYPE_CD, TEXT_RESULT, SPECIMEN_COLLECT_DT, DATE_DIFF)])
}

cat("\nAnalysis complete!\n")


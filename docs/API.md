# API Documentation

This document provides detailed API documentation for the Clinical Lab Analysis Pipeline R scripts.

## Table of Contents

- [Data Preparation Script](#data-preparation-script)
- [Lab Analysis Script](#lab-analysis-script)
- [Helper Functions](#helper-functions)
- [Data Structures](#data-structures)
- [Error Handling](#error-handling)

## Data Preparation Script

### Script: `01_data_preparation.R`

#### Purpose
Processes raw CSV files into optimized RDS format for use in the lab analysis script.

#### Command Line Interface

```bash
Rscript 01_data_preparation.R [options]
```

#### Arguments

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--cohort_file` | string | `cohortmrn_merge.data.csv` | Path to cohort file |
| `--lab_file` | string | `OUTPT_LAB_RESULTS_LABS.csv` | Path to lab results file |
| `--cancer_file` | string | `CANCER_DIAGNOSIS_CAREG.csv` | Path to cancer diagnosis file |
| `--input_dir` | string | Current directory | Input directory containing data files |
| `--output_dir` | string | `./prepared_data` | Output directory for RDS files |

#### Functions

##### `create_parser()`
Creates and configures the argument parser.

**Returns:** `ArgumentParser` object

**Example:**
```r
parser <- create_parser()
args <- parser$parse_args()
```

##### `print_stage(stage, message, ...)`
Prints formatted stage messages.

**Parameters:**
- `stage` (string): Stage identifier
- `message` (string): Message to print
- `...`: Additional arguments passed to `cat()`

**Example:**
```r
print_stage("1", "Reading cohort data...")
```

##### `print_progress(current, total, item_name = "items")`
Prints progress information.

**Parameters:**
- `current` (integer): Current item number
- `total` (integer): Total number of items
- `item_name` (string): Name of items being processed

**Example:**
```r
print_progress(5, 100, "patients")
```

##### `prepare_data(args)`
Main data preparation function.

**Parameters:**
- `args` (list): Parsed command line arguments

**Returns:** List containing:
- `cohort`: Processed cohort data
- `lab_subset`: Lab results subset
- `cancer_subset`: Cancer diagnosis subset
- `summary_stats`: Summary statistics

**Example:**
```r
result <- prepare_data(args)
```

#### Output Files

| File | Description | Format |
|------|-------------|--------|
| `cohort.rds` | Processed cohort data | RDS |
| `lab_subset.rds` | Lab results subset | RDS |
| `cancer_subset.rds` | Cancer diagnosis subset | RDS |
| `lab_results.rds` | Full lab results | RDS |
| `cancer_diag.rds` | Full cancer diagnosis | RDS |
| `data_preparation_summary.csv` | Processing statistics | CSV |
| `data_preparation_summary.txt` | Text summary | TXT |

## Lab Analysis Script

### Script: `02_lab_analysis.R`

#### Purpose
Creates wide-format matrices for analysis using prepared RDS files.

#### Command Line Interface

```bash
Rscript 02_lab_analysis.R [options]
```

#### Arguments

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--input_dir` | string | Required | Input directory containing RDS files |
| `--n_patients` | string | `5` | Number of patients to process (use 'all' for all) |
| `--output_dir` | string | `./lab_analysis_results` | Output directory for results |
| `--max_date_diff` | integer | `365` | Maximum date difference in days |
| `--remove_digit_cols` | flag | `TRUE` | Remove columns with only digit names |

#### Functions

##### `create_parser()`
Creates and configures the argument parser.

**Returns:** `ArgumentParser` object

**Example:**
```r
parser <- create_parser()
args <- parser$parse_args()
```

##### `find_nearest_lab_results(patient_mrn, reference_date, test_type = NULL, max_date_diff = 365)`
Finds the nearest lab results for a patient and test type.

**Parameters:**
- `patient_mrn` (string): Patient medical record number
- `reference_date` (Date): Reference date for matching
- `test_type` (string, optional): Test type code to filter by
- `max_date_diff` (integer): Maximum date difference in days

**Returns:** `data.table` with columns:
- `DFCI_MRN`: Patient medical record number
- `TEST_TYPE_CD`: Test type code
- `TEXT_RESULT`: Lab result value
- `SPECIMEN_COLLECT_DT`: Collection date
- `DATE_DIFF`: Date difference in days

**Example:**
```r
result <- find_nearest_lab_results("12345", as.Date("2020-01-15"), "12345", 365)
```

##### `perform_lab_analysis(args, n_patients)`
Main lab analysis function.

**Parameters:**
- `args` (list): Parsed command line arguments
- `n_patients` (integer): Number of patients to process

**Returns:** List containing:
- `lab_result_wide`: Wide format lab results matrix
- `lab_date_wide`: Wide format lab dates matrix
- `lab_result_matrix_with_dates`: Detailed results with date differences
- `summary_stats`: Analysis summary statistics

**Example:**
```r
result <- perform_lab_analysis(args, 10)
```

#### Output Files

| File | Description | Format |
|------|-------------|--------|
| `lab_result_matrix.csv/.rds` | Wide format lab results | CSV/RDS |
| `lab_date_matrix.csv/.rds` | Wide format lab dates | CSV/RDS |
| `detailed_lab_results.csv/.rds` | Detailed results with date differences | CSV/RDS |
| `summary_statistics.csv` | Analysis summary | CSV |
| `lab_analysis_summary.txt` | Text summary | TXT |

## Helper Functions

### Common Functions

#### `print_stage(stage, message, ...)`
Prints formatted stage messages.

**Parameters:**
- `stage` (string): Stage identifier
- `message` (string): Message to print
- `...`: Additional arguments passed to `cat()`

#### `print_progress(current, total, item_name = "items")`
Prints progress information.

**Parameters:**
- `current` (integer): Current item number
- `total` (integer): Total number of items
- `item_name` (string): Name of items being processed

## Data Structures

### Input Data Formats

#### Cohort Data
Required columns:
- `DFCI_MRN`: Patient medical record number (string)
- `REPORT_DT`: Report date (string, format: DD-MMM-YY)

#### Lab Results Data
Required columns:
- `DFCI_MRN`: Patient medical record number (string)
- `SPECIMEN_COLLECT_DT`: Specimen collection date (string, format: YYYY-MM-DD)
- `TEST_TYPE_CD`: Test type code (string)
- `TEST_TYPE_DESCR`: Test type description (string)
- `TEXT_RESULT`: Lab result value (string)

#### Cancer Diagnosis Data
Required columns:
- `DFCI_MRN`: Patient medical record number (string)
- `SITE_DESCR`: Cancer site description (string)
- `HISTOLOGY_DESCR`: Histology description (string)
- `GRADE_DIFF_DESC`: Grade/differentiation description (string)
- `DATE_FIRST_BIOPSY`: First biopsy date (string, format: YYYY-MM-DD)
- `SSDI_KI_67`: Ki-67 index (numeric)
- `SURVIVAL_AFTER_DIAGNOSIS_NBR`: Survival days after diagnosis (numeric)

### Output Data Formats

#### Lab Result Matrix
Format: Wide format (patients × test types)
Columns:
- `DFCI_MRN`: Patient medical record number
- `REPORT_DT`: Report date
- `[TEST_TYPE_CD]...`: Test type codes as column names
Values: Lab result values (`TEXT_RESULT`)

#### Lab Date Matrix
Format: Wide format (patients × test types)
Columns:
- `DFCI_MRN`: Patient medical record number
- `REPORT_DT`: Report date
- `[TEST_TYPE_CD]...`: Test type codes as column names
Values: Collection dates (`SPECIMEN_COLLECT_DT`)

#### Detailed Lab Results
Format: Long format
Columns:
- `DFCI_MRN`: Patient medical record number
- `TEST_TYPE_CD`: Test type code
- `TEXT_RESULT`: Lab result value
- `SPECIMEN_COLLECT_DT`: Collection date
- `DATE_DIFF`: Date difference in days
- `REPORT_DT`: Report date

## Error Handling

### Common Errors

#### File Not Found
**Error:** `Cohort file not found: /path/to/file.csv`
**Solution:** Check file path and ensure file exists

#### Invalid Date Format
**Error:** `Error in as.Date() : character string is not in a standard unambiguous format`
**Solution:** Ensure dates are in correct format (DD-MMM-YY for cohort, YYYY-MM-DD for lab data)

#### Memory Issues
**Error:** `Error: cannot allocate vector of size X Mb`
**Solution:** Process fewer patients or increase system memory

#### Package Not Found
**Error:** `Error in library(data.table) : there is no package called 'data.table'`
**Solution:** Install required packages: `install.packages(c("data.table", "argparse"))`

### Error Handling Functions

#### `tryCatch()`
Used for error handling in main execution blocks.

**Example:**
```r
tryCatch({
  result <- prepare_data(args)
  quit(status = 0)
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
  quit(status = 1)
})
```

## Performance Considerations

### Memory Usage
- Use `data.table` for efficient data manipulation
- Process data in chunks for large datasets
- Use RDS format for faster loading

### Processing Time
- Date matching is the most time-consuming operation
- Consider using parallel processing for large datasets
- Monitor progress with `print_progress()`

### Optimization Tips
- Use appropriate data types
- Avoid unnecessary data copying
- Use `data.table` operations efficiently
- Consider using `fread()` for large CSV files

## Examples

### Basic Usage
```r
# Data preparation
Rscript 01_data_preparation.R --input_dir /path/to/data --output_dir ./prepared

# Lab analysis
Rscript 02_lab_analysis.R --input_dir ./prepared --n_patients 10 --output_dir ./results
```

### Advanced Usage
```r
# Custom file names
Rscript 01_data_preparation.R \
  --cohort_file my_cohort.csv \
  --lab_file my_labs.csv \
  --cancer_file my_cancer.csv \
  --input_dir /data \
  --output_dir ./prepared

# Custom parameters
Rscript 02_lab_analysis.R \
  --input_dir ./prepared \
  --n_patients 25 \
  --max_date_diff 180 \
  --output_dir ./results
```

### Programmatic Usage
```r
# Load required libraries
library(data.table)
library(argparse)

# Create parser
parser <- create_parser()
args <- parser$parse_args()

# Run analysis
result <- perform_lab_analysis(args, 10)

# Access results
lab_matrix <- result$lab_result_wide
summary_stats <- result$summary_stats
```

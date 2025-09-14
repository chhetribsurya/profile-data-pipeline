# Clinical Lab Results Based Extraction and Analysis Pipeline

A R-based pipeline for processing and analyzing clinical data. This pipeline processes cohort data, laboratory results, and cancer diagnosis information to create wide-format matrices for downstream analysis.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/chhetribsurya/profile-data-pipeline.git
cd clinical-lab-analysis-pipeline

# Make the wrapper script executable
chmod +x run_analysis.sh

# Run complete pipeline with 5 patients (testing)
./run_analysis.sh full --input_dir /path/to/your/data --n_patients 5

# Run complete pipeline with all patients
./run_analysis.sh full --input_dir /path/to/your/data --n_patients all
```

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Data Requirements](#data-requirements)
- [Usage](#usage)
- [Pipeline Components](#pipeline-components)
- [Output Files](#output-files)
- [Configuration Options](#configuration-options)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

This pipeline is designed to process clinical data from DFCI's electronic health records system. It takes raw CSV files containing cohort information, laboratory results, and cancer diagnoses, and creates structured datasets suitable for research analysis.

### Key Capabilities and Features

- **Data Preparation**: Processes raw CSV files into optimized RDS format
- **Lab Analysis**: Creates wide-format matrices with lab results and dates
- **Intelligent Date Matching**: Finds nearest lab results within specified time windows
- **Flexible Processing**: Supports processing subsets or all patients
- **Comprehensive Reporting**: Generates detailed summaries and statistics
- **Duplicate Handling**: Intelligent handling of multiple lab results per patient
- **Multiple Output Formats**: Long format, wide format, and suffix-based matrices
- **Force Reprocessing**: Option to override caching when needed
- **Smart Caching System**: RDS file caching and automatically uses cached results to avoid reprocessing
- **Progress Tracking**: Real-time progress updates during processing

## Requirements

### System Requirements

- **R** (version 3.6 or higher)
- **R packages**: `data.table`, `argparse`
- **Operating System**: Linux, macOS, or Windows (with R installed)
- **Memory**: Minimum 4GB RAM (8GB+ recommended for large datasets)
- **Storage**: Sufficient space for input data and output files

### R Package Installation

```r
# Install required packages
install.packages(c("data.table", "argparse"))

# Or install from CRAN
install.packages("data.table")
install.packages("argparse")
```

## Installation

### Method 1: Clone Repository

```bash
git clone https://github.com/chhetribsurya/profile-data-pipeline.git
cd profile-data-pipeline
chmod +x run_analysis.sh
```

### Method 2: Download ZIP

1. Download the repository as a ZIP file
2. Extract to your desired location
3. Make the wrapper script executable: `chmod +x run_analysis.sh`

## Data Requirements

The pipeline expects three main input files in CSV format:

### Required Input Files

1. **Cohort File** (`cohortmrn_merge.data.csv`)
   - Contains patient cohort information
   - Must include columns: `DFCI_MRN`, `REPORT_DT`

2. **Lab Results File** (`OUTPT_LAB_RESULTS_LABS.csv`)
   - Contains laboratory test results
   - Must include columns: `DFCI_MRN`, `SPECIMEN_COLLECT_DT`, `TEST_TYPE_CD`, `TEST_TYPE_DESCR`, `TEXT_RESULT`

3. **Cancer Diagnosis File** (`CANCER_DIAGNOSIS_CAREG.csv`)
   - Contains cancer diagnosis information
   - Must include columns: `DFCI_MRN`, `SITE_DESCR`, `HISTOLOGY_DESCR`, `GRADE_DIFF_DESC`, `DATE_FIRST_BIOPSY`, `SSDI_KI_67`, `SURVIVAL_AFTER_DIAGNOSIS_NBR`

### Data Format Requirements

- **File Format**: CSV with comma separators
- **Date Format**: `DD-MMM-YY` (e.g., "15-Jan-20")
- **Encoding**: UTF-8 recommended
- **Missing Values**: Empty cells or NA values are handled appropriately

## Usage

### Quick Start Commands

```bash
# Run complete pipeline (recommended for first-time users)
./run_analysis.sh full --input_dir /path/to/data --n_patients 5

# Run only data preparation
./run_analysis.sh prepare --input_dir /path/to/data

# Run only lab analysis (requires prepared data)
./run_analysis.sh analyze --input_dir ./prepared_data --n_patients 10
```

### Advanced Usage

```bash
# Process all patients with custom settings
./run_analysis.sh full \
  --input_dir /data/clinical \
  --output_dir ./results \
  --n_patients all \
  --max_date_diff 180

# Process specific number of patients
./run_analysis.sh full \
  --input_dir /data/clinical \
  --n_patients 100 \
  --max_date_diff 365
```

### Individual Script Usage

```bash
# Data preparation only
Rscript 01_data_preparation.R \
  --input_dir /path/to/data \
  --output_dir ./prepared_data

# Lab analysis only
Rscript 02_lab_analysis.R \
  --input_dir ./prepared_data \
  --n_patients 5 \
  --output_dir ./results
```

## Pipeline Components

### 1. Data Preparation Script (`01_data_preparation.R`)

**Purpose**: Processes raw CSV files into optimized RDS format

**Key Functions**:
- Reads and validates input CSV files
- Creates subsets with relevant columns
- Calculates overlap statistics between datasets
- Saves processed data as RDS files for faster loading

**Output Files**:
- `cohort.rds`: Processed cohort data
- `lab_subset.rds`: Lab results subset
- `cancer_subset.rds`: Cancer diagnosis subset
- `lab_results.rds`: Full lab results
- `cancer_diag.rds`: Full cancer diagnosis
- `data_preparation_summary.txt`: Processing summary

### 2. Lab Analysis Script (`02_lab_analysis.R`)

**Purpose**: Creates wide-format matrices for analysis

**Key Functions**:
- Finds nearest lab results within time windows
- Creates patient × test type matrices
- Handles missing data appropriately
- Generates comprehensive reports

**Output Files**:
- `lab_result_matrix.csv/.rds`: Wide format lab results (deduplicated)
- `lab_date_matrix.csv/.rds`: Wide format lab dates (deduplicated)
- `detailed_lab_results.csv/.rds`: Detailed results with date differences (deduplicated)
- `lab_results_long_format.csv/.rds`: Long format with ALL lab results (including duplicates)
- `lab_result_matrix_with_suffixes.csv/.rds`: Wide format with MRN suffixes for multiple test types
- `lab_date_matrix_with_suffixes.csv/.rds`: Wide format dates with MRN suffixes
- `summary_statistics.csv`: Analysis summary

### 3. Wrapper Script (`run_analysis.sh`)

**Purpose**: Provides easy-to-use interface for the complete pipeline

**Commands**:
- `prepare`: Run data preparation only
- `analyze`: Run lab analysis only
- `full`: Run complete pipeline
- `help`: Show help message

## Prepared Data Structure

After running the data preparation step, your `./prepared_data/` directory will contain the following files:

### Minimal Setup (Required Files Only)
```
./prepared_data/
├── cohort.rds          # ✅ Required - Processed cohort data
└── lab_subset.rds      # ✅ Required - Lab results subset
```

### Complete Setup (With Optional Files)
```
./prepared_data/
├── cohort.rds          # ✅ Required - Processed cohort data
├── lab_subset.rds      # ✅ Required - Lab results subset
└── cancer_subset.rds   # ⚪ Optional - Cancer diagnosis subset
```

### Additional Files (Created by Data Preparation)
```
./prepared_data/
├── cohort.rds                    # ✅ Required
├── lab_subset.rds                # ✅ Required
├── cancer_subset.rds             # ⚪ Optional
├── lab_results.rds               # 📦 Full lab results (backup)
├── cancer_diag.rds               # 📦 Full cancer diagnosis (backup)
├── data_preparation_summary.csv  # 📊 Processing statistics
└── data_preparation_summary.txt  # 📄 Text summary report
```

**Note**: The lab analysis script only requires `cohort.rds` and `lab_subset.rds`. The cancer data and additional files are optional.

## Output Files

### Data Preparation Outputs

| File | Description | Format |
|------|-------------|--------|
| `cohort.rds` | Processed cohort data | RDS |
| `lab_subset.rds` | Lab results subset | RDS |
| `cancer_subset.rds` | Cancer diagnosis subset | RDS |
| `lab_results.rds` | Full lab results | RDS |
| `cancer_diag.rds` | Full cancer diagnosis | RDS |
| `data_preparation_summary.csv` | Processing statistics | CSV |
| `data_preparation_summary.txt` | Text summary | TXT |

### Lab Analysis Outputs

| File | Description | Format |
|------|-------------|--------|
| `lab_result_matrix.csv/.rds` | Wide format lab results (deduplicated) | CSV/RDS |
| `lab_date_matrix.csv/.rds` | Wide format lab dates (deduplicated) | CSV/RDS |
| `detailed_lab_results.csv/.rds` | Detailed results with date differences (deduplicated) | CSV/RDS |
| `lab_results_long_format.csv/.rds` | Long format with ALL lab results (including duplicates) | CSV/RDS |
| `lab_result_matrix_with_suffixes.csv/.rds` | Wide format with MRN suffixes for multiple test types | CSV/RDS |
| `lab_date_matrix_with_suffixes.csv/.rds` | Wide format dates with MRN suffixes | CSV/RDS |
| `summary_statistics.csv` | Analysis summary | CSV |
| `lab_analysis_summary.txt` | Text summary | TXT |

### Output File Descriptions

#### Lab Result Matrix
- **Format**: Wide format (patients × test types)
- **Columns**: `DFCI_MRN`, `REPORT_DT`, `[TEST_TYPE_CD]...`
- **Values**: Lab result values (`TEXT_RESULT`)
- **Missing Values**: NA for missing results

#### Lab Date Matrix
- **Format**: Wide format (patients × test types)
- **Columns**: `DFCI_MRN`, `REPORT_DT`, `[TEST_TYPE_CD]...`
- **Values**: Collection dates (`SPECIMEN_COLLECT_DT`)
- **Missing Values**: NA for missing dates

#### Detailed Lab Results
- **Format**: Long format
- **Columns**: `DFCI_MRN`, `TEST_TYPE_CD`, `TEXT_RESULT`, `SPECIMEN_COLLECT_DT`, `DATE_DIFF`, `REPORT_DT`
- **Purpose**: Detailed view of all lab results with date differences (deduplicated)

#### Lab Results Long Format
- **Format**: Long format
- **Columns**: `DFCI_MRN`, `TEST_TYPE_CD`, `TEXT_RESULT`, `SPECIMEN_COLLECT_DT`, `DATE_DIFF`, `REPORT_DT`
- **Purpose**: Complete dataset with ALL lab results including duplicates
- **Use Case**: Comprehensive analysis without any data loss

#### Lab Result Matrix with Suffixes
- **Format**: Wide format (patients × test types)
- **Columns**: `ORIGINAL_MRN`, `UNIQUE_MRN`, `REPORT_DT`, `[TEST_TYPE_CD]...`
- **Values**: Lab result values (`TEXT_RESULT`)
- **Purpose**: Handles multiple test types per patient using MRN suffixes
- **Use Case**: Resolves duplicate MRN issues in matrix format

#### Lab Date Matrix with Suffixes
- **Format**: Wide format (patients × test types)
- **Columns**: `ORIGINAL_MRN`, `UNIQUE_MRN`, `REPORT_DT`, `[TEST_TYPE_CD]...`
- **Values**: Collection dates (`SPECIMEN_COLLECT_DT`)
- **Purpose**: Corresponding dates for suffix-based matrix
- **Use Case**: Date tracking for multiple test types per patient

## Configuration Options

### Command Line Arguments

#### Data Preparation Script

| Argument | Default | Description |
|----------|---------|-------------|
| `--cohort_file` | `cohortmrn_merge.data.csv` | Path to cohort file |
| `--lab_file` | `OUTPT_LAB_RESULTS_LABS.csv` | Path to lab results file |
| `--cancer_file` | `CANCER_DIAGNOSIS_CAREG.csv` | Path to cancer diagnosis file |
| `--input_dir` | Current directory | Input directory containing data files |
| `--output_dir` | `./prepared_data` | Output directory for RDS files |

#### Lab Analysis Script

| Argument | Default | Description |
|----------|---------|-------------|
| `--input_dir` | Required | Input directory containing RDS files |
| `--n_patients` | `5` | Number of patients to process (use 'all' for all) |
| `--output_dir` | `./lab_analysis_results` | Output directory for results |
| `--max_date_diff` | `365` | Maximum date difference in days |
| `--remove_digit_cols` | `TRUE` | Remove columns with only digit names |
| `--force_reprocess` | `FALSE` | Force reprocessing even if cached results exist |

#### Wrapper Script

| Argument | Default | Description |
|----------|---------|-------------|
| `--input_dir` | Required | Input directory containing raw data files |
| `--output_dir` | `./prepared_data` | Output directory for results |
| `--n_patients` | `5` | Number of patients to process |
| `--max_date_diff` | `365` | Maximum date difference in days |
| `--no_remove_digits` | `false` | Don't remove digit-only columns |

## New Features

### Smart Caching System

The pipeline now includes an intelligent caching system that automatically detects and uses previously processed results:

- **Automatic Detection**: Checks if RDS files exist and are newer than input files
- **Instant Loading**: Loads cached results instead of reprocessing
- **Force Override**: Use `--force_reprocess` to override caching when needed
- **Performance Boost**: Significantly faster subsequent runs

```bash
# First run - full processing
Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients all

# Second run - loads from cache (instant!)
Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients all

# Force reprocessing even if cache exists
Rscript 02_lab_analysis.R --input_dir ./prepared_data --n_patients all --force_reprocess
```

### Duplicate Handling with MRN Suffixes

The pipeline now intelligently handles multiple lab results per patient:

- **Problem Solved**: Eliminates the 1,2,3,4,5 count values in matrices
- **MRN Suffixes**: Creates unique identifiers (e.g., `12345_1`, `12345_2`)
- **Preserves Data**: Keeps all lab results without data loss
- **Multiple Formats**: Provides both deduplicated and complete datasets

**Example Output:**
```
ORIGINAL_MRN | UNIQUE_MRN | REPORT_DT  | HEMOGLOBIN | CREATININE | GLUCOSE
-------------|------------|------------|------------|------------|--------
12345        | 12345_1    | 2023-01-15 | 12.5       | 1.2        | 95
12345        | 12345_2    | 2023-01-15 | 13.2       | 1.4        | NA
```

### Multiple Output Formats

The pipeline now generates comprehensive output files:

1. **Deduplicated Matrices**: Standard wide format with nearest lab results
2. **Long Format**: Complete dataset with all lab results including duplicates
3. **Suffix Matrices**: Wide format with MRN suffixes for multiple test types
4. **Date Matrices**: Corresponding date information for all formats

## Examples

### Example 1: Basic Usage

```bash
# Set up your data directory
mkdir -p /path/to/clinical_data
# Copy your CSV files to this directory

# Run the complete pipeline
./run_analysis.sh full --input_dir /path/to/clinical_data --n_patients 5
```

### Example 2: Processing All Patients

```bash
# Process all patients with custom output directory
./run_analysis.sh full \
  --input_dir /data/clinical \
  --output_dir ./results_$(date +%Y%m%d) \
  --n_patients all
```

### Example 3: Custom Date Window

```bash
# Use 6-month date window instead of 1 year
./run_analysis.sh full \
  --input_dir /data/clinical \
  --n_patients 50 \
  --max_date_diff 180
```

### Example 4: Step-by-Step Processing

```bash
# Step 1: Prepare data
./run_analysis.sh prepare --input_dir /data/clinical --output_dir ./prepared

# Step 2: Analyze with different settings
./run_analysis.sh analyze --input_dir ./prepared --n_patients 10 --output_dir ./results_10
./run_analysis.sh analyze --input_dir ./prepared --n_patients 100 --output_dir ./results_100
```

### Example 5: Using Individual Scripts

```bash
# Data preparation with custom file names
Rscript 01_data_preparation.R \
  --cohort_file my_cohort.csv \
  --lab_file my_labs.csv \
  --cancer_file my_cancer.csv \
  --input_dir /data \
  --output_dir ./prepared

# Lab analysis with custom parameters
Rscript 02_lab_analysis.R \
  --input_dir ./prepared \
  --n_patients 25 \
  --max_date_diff 90 \
  --output_dir ./analysis_results
```

## 🔍 Troubleshooting

### Common Issues

#### 1. R Package Not Found

**Error**: `Error in library(data.table) : there is no package called 'data.table'`

**Solution**:
```r
install.packages(c("data.table", "argparse"))
```

#### 2. Input File Not Found

**Error**: `Cohort file not found: /path/to/file.csv`

**Solution**:
- Check file path and name
- Ensure files are in the specified input directory
- Verify file permissions

#### 3. Memory Issues

**Error**: `Error: cannot allocate vector of size X Mb`

**Solution**:
- Process fewer patients at a time
- Increase system memory
- Use `--n_patients` to limit processing

#### 4. Date Format Issues

**Error**: `Error in as.Date() : character string is not in a standard unambiguous format`

**Solution**:
- Ensure dates are in `DD-MMM-YY` format
- Check for special characters or encoding issues
- Verify date column names

#### 5. Permission Denied

**Error**: `Permission denied: ./run_analysis.sh`

**Solution**:
```bash
chmod +x run_analysis.sh
```

### Performance Optimization

#### For Large Datasets

1. **Use RDS format**: RDS files load faster than CSV
2. **Process in batches**: Use `--n_patients` to process subsets
3. **Increase memory**: Ensure sufficient RAM for large datasets
4. **Use SSD storage**: Faster I/O for large files

#### Memory Usage Guidelines

| Dataset Size | Recommended RAM | Processing Time |
|--------------|-----------------|-----------------|
| < 1,000 patients | 4GB | < 5 minutes |
| 1,000-10,000 patients | 8GB | 5-30 minutes |
| > 10,000 patients | 16GB+ | 30+ minutes |

### Debugging Tips

1. **Start small**: Always test with `--n_patients 5` first
2. **Check logs**: Review output messages for errors
3. **Verify data**: Check input file formats and content
4. **Monitor resources**: Watch memory and disk usage

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork the repository
git clone https://github.com/chhetribsurya/profile-data-pipeline.git
cd profile-data-pipeline

# Create a development branch
git checkout -b feature/your-feature-name

# Make your changes
# Test your changes
./run_analysis.sh full --input_dir test_data --n_patients 5

# Commit and push
git add .
git commit -m "Add your feature"
git push origin feature/your-feature-name
```

### Reporting Issues

Please use our [Issue Tracker](https://github.com/chhetribsurya/profile-data-pipeline/issues) to report bugs or request features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Version History

- **v1.0.0**: Initial release with basic pipeline functionality
- **v1.1.0**: Added wrapper script and improved error handling
- **v1.2.0**: Enhanced reporting and configuration options
- **v2.0.0**: Major update with smart caching, duplicate handling, and multiple output formats
  - Added intelligent RDS file caching system
  - Implemented MRN suffix system for duplicate handling
  - Added long format output with all lab results
  - Added suffix-based matrices for multiple test types per patient
  - Added force reprocessing option
  - Enhanced documentation and examples

---

**Note**: This pipeline is designed for research purposes. Ensure compliance with institutional data use agreements and privacy regulations when processing clinical data.

# Clinical Lab Analysis Pipeline

A R-based pipeline for processing and analyzing clinical data. This pipeline processes cohort data, laboratory results, and cancer diagnosis information to create wide-format matrices for downstream analysis.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/clinical-lab-analysis-pipeline.git
cd clinical-lab-analysis-pipeline

# Make the wrapper script executable
chmod +x run_analysis.sh

# Run complete pipeline with 5 patients (testing)
./run_analysis.sh full --input_dir /path/to/your/data --n_patients 5

# Run complete pipeline with all patients
./run_analysis.sh full --input_dir /path/to/your/data --n_patients all
```

## 📋 Table of Contents

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

## 🔍 Overview

This pipeline is designed to process clinical data from DFCI's electronic health records system. It takes raw CSV files containing cohort information, laboratory results, and cancer diagnoses, and creates structured datasets suitable for research analysis.

### Key Capabilities

- **Data Preparation**: Processes raw CSV files into optimized RDS format
- **Lab Analysis**: Creates wide-format matrices with lab results and dates
- **Date Matching**: Finds nearest lab results within specified time windows
- **Flexible Processing**: Supports processing subsets or all patients
- **Comprehensive Reporting**: Generates detailed summaries and statistics

## ✨ Features

- 🏥 **Clinical Data Processing**: Handles cohort, lab results, and cancer diagnosis data
- 📊 **Wide Format Matrices**: Creates patient × test type matrices for analysis
- 📅 **Intelligent Date Matching**: Finds nearest lab results within configurable time windows
- 🔧 **Flexible Configuration**: Command-line options for all major parameters
- 📈 **Progress Tracking**: Real-time progress updates during processing
- 📋 **Comprehensive Reporting**: Detailed summaries and statistics
- 🚀 **Easy-to-Use Wrapper**: Single script to run complete pipeline
- 💾 **Optimized Storage**: RDS format for fast loading and small file sizes

## 📦 Requirements

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

## 🛠️ Installation

### Method 1: Clone Repository

```bash
git clone https://github.com/your-username/clinical-lab-analysis-pipeline.git
cd clinical-lab-analysis-pipeline
chmod +x run_analysis.sh
```

### Method 2: Download ZIP

1. Download the repository as a ZIP file
2. Extract to your desired location
3. Make the wrapper script executable: `chmod +x run_analysis.sh`

## 📁 Data Requirements

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

## 🚀 Usage

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

## 🔧 Pipeline Components

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
- `lab_result_matrix.csv/.rds`: Wide format lab results
- `lab_date_matrix.csv/.rds`: Wide format lab dates
- `detailed_lab_results.csv/.rds`: Detailed results with date differences
- `summary_statistics.csv`: Analysis summary

### 3. Wrapper Script (`run_analysis.sh`)

**Purpose**: Provides easy-to-use interface for the complete pipeline

**Commands**:
- `prepare`: Run data preparation only
- `analyze`: Run lab analysis only
- `full`: Run complete pipeline
- `help`: Show help message

## 📊 Output Files

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
| `lab_result_matrix.csv/.rds` | Wide format lab results | CSV/RDS |
| `lab_date_matrix.csv/.rds` | Wide format lab dates | CSV/RDS |
| `detailed_lab_results.csv/.rds` | Detailed results with date differences | CSV/RDS |
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
- **Purpose**: Detailed view of all lab results with date differences

## ⚙️ Configuration Options

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

#### Wrapper Script

| Argument | Default | Description |
|----------|---------|-------------|
| `--input_dir` | Required | Input directory containing raw data files |
| `--output_dir` | `./prepared_data` | Output directory for results |
| `--n_patients` | `5` | Number of patients to process |
| `--max_date_diff` | `365` | Maximum date difference in days |
| `--no_remove_digits` | `false` | Don't remove digit-only columns |

## 📚 Examples

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

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork the repository
git clone https://github.com/your-username/clinical-lab-analysis-pipeline.git
cd clinical-lab-analysis-pipeline

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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📈 Version History

- **v1.0.0**: Initial release with basic pipeline functionality
- **v1.1.0**: Added wrapper script and improved error handling
- **v1.2.0**: Enhanced reporting and configuration options

---

**Note**: This pipeline is designed for research purposes. Ensure compliance with institutional data use agreements and privacy regulations when processing clinical data.

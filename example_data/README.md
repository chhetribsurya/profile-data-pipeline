# Example Data

This directory contains example data files for testing the Clinical Lab Analysis Pipeline.

## Files

### Input Data Files

- `cohortmrn_merge.data.csv` - Example cohort data
- `OUTPT_LAB_RESULTS_LABS.csv` - Example lab results data
- `CANCER_DIAGNOSIS_CAREG.csv` - Example cancer diagnosis data

### Output Data Files

- `prepared_data/` - Directory containing prepared RDS files
- `lab_analysis_results/` - Directory containing analysis results

## Usage

### Quick Test

```bash
# Run the complete pipeline with example data
./run_analysis.sh full --input_dir example_data --n_patients 5

# Or run individual steps
./run_analysis.sh prepare --input_dir example_data
./run_analysis.sh analyze --input_dir example_data/prepared_data --n_patients 5
```

### Data Description

#### Cohort Data (`cohortmrn_merge.data.csv`)
- **DFCI_MRN**: Patient medical record number
- **REPORT_DT**: Report date (format: DD-MMM-YY)

#### Lab Results Data (`OUTPT_LAB_RESULTS_LABS.csv`)
- **DFCI_MRN**: Patient medical record number
- **SPECIMEN_COLLECT_DT**: Specimen collection date
- **TEST_TYPE_CD**: Test type code
- **TEST_TYPE_DESCR**: Test type description
- **TEXT_RESULT**: Lab result value

#### Cancer Diagnosis Data (`CANCER_DIAGNOSIS_CAREG.csv`)
- **DFCI_MRN**: Patient medical record number
- **SITE_DESCR**: Cancer site description
- **HISTOLOGY_DESCR**: Histology description
- **GRADE_DIFF_DESC**: Grade/differentiation description
- **DATE_FIRST_BIOPSY**: First biopsy date
- **SSDI_KI_67**: Ki-67 index
- **SURVIVAL_AFTER_DIAGNOSIS_NBR**: Survival days after diagnosis

## Notes

- These are synthetic example data files for testing purposes
- The data does not represent real patients or clinical information
- Use these files to test the pipeline before running with real data
- The example data includes various edge cases and data quality issues for comprehensive testing

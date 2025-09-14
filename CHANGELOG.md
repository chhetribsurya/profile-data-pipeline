# Changelog

All notable changes to the Clinical Lab Analysis Pipeline will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- N/A

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [2.0.0] - 2024-01-15

### Added
- **Smart Caching System**
  - Automatic detection of cached RDS files
  - Instant loading of previously processed results
  - File timestamp validation to ensure data freshness
  - `--force_reprocess` option to override caching
  - Significant performance improvement for repeated runs

- **Duplicate Handling with MRN Suffixes**
  - Intelligent handling of multiple lab results per patient
  - MRN suffix system (e.g., 12345_1, 12345_2) for unique identification
  - Eliminates the 1,2,3,4,5 count values in matrices
  - Preserves all lab results without data loss
  - Resolves duplicate MRN issues in matrix format

- **Multiple Output Formats**
  - `lab_results_long_format.csv/.rds` - Complete dataset with all lab results including duplicates
  - `lab_result_matrix_with_suffixes.csv/.rds` - Wide format with MRN suffixes for multiple test types
  - `lab_date_matrix_with_suffixes.csv/.rds` - Wide format dates with MRN suffixes
  - Enhanced summary statistics with comprehensive metrics

- **Enhanced Documentation**
  - Updated README with new features and examples
  - Example output files demonstrating new formats
  - Comprehensive usage examples for caching and duplicate handling
  - Updated project structure documentation

- **Example Output Files**
  - `example_outputs/` directory with sample output files
  - Demonstrates all new output formats
  - Shows duplicate handling and MRN suffix system
  - Includes comprehensive documentation

### Changed
- **Lab Analysis Script** (`02_lab_analysis.R`)
  - Moved caching check to Stage 0 (before any processing)
  - Enhanced duplicate detection and handling
  - Added MRN suffix generation for multiple test types
  - Improved error handling and debugging information
  - Updated summary statistics to include new metrics

- **Output File Structure**
  - Standard matrices now clearly marked as "deduplicated"
  - New long format files include all data without duplicate removal
  - Suffix-based matrices handle complex patient scenarios
  - Enhanced file descriptions and documentation

- **Command Line Interface**
  - Added `--force_reprocess` argument to override caching
  - Enhanced help text and documentation
  - Updated examples to demonstrate new features

### Fixed
- **Duplicate Issue Resolution**
  - Fixed the 1,2,3,4,5 count values appearing in matrices
  - Proper handling of multiple lab results per patient
  - Eliminated dcast warnings about duplicate combinations
  - Ensured actual lab values are used instead of counts

- **Caching System**
  - Fixed caching check timing (now happens before processing)
  - Proper file timestamp validation
  - Correct handling of missing or outdated cache files

### Performance
- **Caching Benefits**
  - First run: Full processing + saves RDS files
  - Subsequent runs: Instant loading from cache
  - Significant time savings for repeated analysis
  - Automatic cache validation and refresh

- **Memory Optimization**
  - Efficient handling of large datasets with duplicates
  - Optimized data structures for suffix-based matrices
  - Improved memory usage for complex patient scenarios

### Security
- **Data Integrity**
  - Enhanced validation of cached files
  - Proper handling of file permissions
  - Secure data processing without external dependencies

## [1.0.0] - 2024-01-XX

## [1.0.0] - 2024-01-XX

### Added
- **Data Preparation Script** (`01_data_preparation.R`)
  - Command-line argument parsing with argparse
  - Support for custom input/output directories
  - Comprehensive error handling and validation
  - Progress tracking and status reporting
  - Data overlap analysis and statistics
  - RDS file generation for optimized storage
  - Detailed summary reports

- **Lab Analysis Script** (`02_lab_analysis.R`)
  - Wide-format matrix creation for lab results
  - Intelligent date matching within configurable time windows
  - Support for processing subsets or all patients
  - Automatic removal of digit-only columns
  - Comprehensive output generation (CSV and RDS formats)
  - Detailed statistics and reporting

- **Wrapper Script** (`run_analysis.sh`)
  - Easy-to-use interface for complete pipeline
  - Support for prepare, analyze, and full commands
  - Comprehensive help system
  - System requirement checking
  - Color-coded output for better user experience

- **Documentation**
  - Comprehensive README with usage examples
  - Contributing guidelines (CONTRIBUTING.md)
  - MIT License
  - Changelog tracking
  - Requirements and setup instructions

- **Environment Support**
  - R package requirements (requirements.txt)
  - Conda environment configuration (environment.yml)
  - Docker containerization (Dockerfile, docker-compose.yml)
  - Automated setup script (setup.R)

### Features
- **Data Processing**
  - Cohort data processing and validation
  - Laboratory results processing and subsetting
  - Cancer diagnosis data processing
  - Date format conversion and validation
  - Data overlap analysis

- **Lab Analysis**
  - Nearest date matching algorithm
  - Wide-format matrix creation
  - Missing data handling
  - Configurable time windows
  - Patient subset processing

- **Output Generation**
  - Multiple output formats (CSV, RDS)
  - Comprehensive summary statistics
  - Detailed reporting
  - Progress tracking
  - Error logging

- **User Experience**
  - Command-line interface
  - Help system and documentation
  - Progress indicators
  - Error handling and validation
  - Flexible configuration options

### Technical Details
- **R Dependencies**: data.table, argparse
- **Supported Platforms**: Linux, macOS, Windows
- **R Version**: 3.6 or higher
- **Memory Requirements**: 4GB minimum, 8GB+ recommended
- **File Formats**: CSV input, CSV/RDS output

### Performance
- **Optimized Data Processing**: Uses data.table for efficient data manipulation
- **Memory Efficient**: RDS format for faster loading and smaller file sizes
- **Scalable**: Supports processing from small datasets to large clinical databases
- **Configurable**: Adjustable parameters for different use cases

### Security
- **Data Privacy**: No data transmission to external services
- **Local Processing**: All analysis performed locally
- **Input Validation**: Comprehensive validation of input files and parameters
- **Error Handling**: Graceful handling of errors and edge cases

## [0.9.0] - 2024-01-XX (Pre-release)

### Added
- Initial development version
- Basic data preparation functionality
- Lab analysis with date matching
- Command-line interface
- Basic documentation

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## Release Notes

### Version 1.0.0
This is the first stable release of the Clinical Lab Analysis Pipeline. It provides a complete solution for processing clinical laboratory data from DFCI's electronic health records system.

**Key Features:**
- Complete data preparation and analysis pipeline
- Support for large-scale clinical datasets
- Comprehensive documentation and examples
- Multiple deployment options (local, Docker, Conda)
- Extensive configuration options

**Breaking Changes:**
- None (first release)

**Migration Guide:**
- N/A (first release)

### Version 0.9.0
This was the pre-release version used for initial testing and development.

**Key Features:**
- Basic pipeline functionality
- Initial data processing capabilities
- Command-line interface

**Breaking Changes:**
- N/A (pre-release)

**Migration Guide:**
- N/A (pre-release)

---

## Contributing

To contribute to this changelog, please follow the format specified in [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

### Changelog Guidelines

1. **Use clear, descriptive language**
2. **Group changes by type** (Added, Changed, Deprecated, Removed, Fixed, Security)
3. **Include version numbers** and dates
4. **Reference issues and pull requests** when applicable
5. **Use present tense** for new entries
6. **Use past tense** for completed changes

### Example Entry

```markdown
### Added
- New feature for processing additional data types
- Support for custom date formats
- Enhanced error reporting

### Changed
- Improved performance for large datasets
- Updated default parameters

### Fixed
- Resolved memory issue with large files
- Fixed date parsing error for edge cases
```

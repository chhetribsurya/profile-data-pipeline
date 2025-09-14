# Project Structure

This document provides an overview of the Clinical Lab Analysis Pipeline project structure.

## Directory Structure

```
clinical-lab-analysis-pipeline/
├── README.md                           # Main project documentation
├── LICENSE                             # MIT License
├── CONTRIBUTING.md                     # Contributing guidelines
├── CHANGELOG.md                        # Version history
├── CONTRIBUTORS.md                     # Contributors list
├── PROJECT_STRUCTURE.md               # This file
├── requirements.txt                    # R package requirements
├── setup.R                            # Environment setup script
├── environment.yml                     # Conda environment configuration
├── Dockerfile                          # Docker container configuration
├── docker-compose.yml                  # Docker Compose configuration
├── .gitignore                          # Git ignore rules
├── run_analysis.sh                     # Main pipeline wrapper script
├── 01_data_preparation.R               # Data preparation script
├── 02_lab_analysis.R                   # Lab analysis script
├── profile_access.R                    # Legacy profile access script
├── .github/                            # GitHub-specific files
│   ├── workflows/
│   │   └── ci.yml                      # CI/CD workflow
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md               # Bug report template
│       ├── feature_request.md          # Feature request template
│       └── question.md                 # Question template
│   └── PULL_REQUEST_TEMPLATE.md        # Pull request template
├── docs/                               # Additional documentation
│   ├── README.md                       # Documentation index
│   ├── API.md                          # API documentation
│   ├── TROUBLESHOOTING.md              # Troubleshooting guide
│   ├── PERFORMANCE.md                  # Performance optimization guide
│   └── DEPLOYMENT.md                   # Deployment guide
├── example_data/                       # Example data files
│   ├── README.md                       # Example data documentation
│   ├── cohortmrn_merge.data.csv       # Example cohort data
│   ├── OUTPT_LAB_RESULTS_LABS.csv     # Example lab results
│   └── CANCER_DIAGNOSIS_CAREG.csv     # Example cancer diagnosis
├── example_outputs/                    # Example output files (v2.0.0)
│   ├── README.md                       # Example outputs documentation
│   ├── lab_result_matrix.csv          # Standard wide format (deduplicated)
│   ├── lab_date_matrix.csv            # Standard wide format dates
│   ├── detailed_lab_results.csv       # Detailed results (deduplicated)
│   ├── lab_results_long_format.csv    # Long format (all data)
│   ├── lab_result_matrix_with_suffixes.csv # Wide format with MRN suffixes
│   ├── lab_date_matrix_with_suffixes.csv   # Wide format dates with suffixes
│   ├── summary_statistics.csv         # Analysis summary
│   └── lab_analysis_summary.txt       # Text summary report
└── examples/                           # Usage examples
    ├── README.md                       # Examples documentation
    ├── basic_usage.sh                  # Basic usage examples
    └── advanced_config.sh              # Advanced configuration examples
```

## File Descriptions

### Core Scripts

| File | Description | Purpose |
|------|-------------|---------|
| `run_analysis.sh` | Main pipeline wrapper | Easy-to-use interface for the complete pipeline |
| `01_data_preparation.R` | Data preparation script | Processes raw CSV files into RDS format |
| `02_lab_analysis.R` | Lab analysis script | Creates wide-format matrices for analysis |
| `profile_access.R` | Legacy script | Original profile access implementation |

### Documentation

| File | Description | Audience |
|------|-------------|----------|
| `README.md` | Main documentation | All users |
| `CONTRIBUTING.md` | Contributing guidelines | Developers |
| `CHANGELOG.md` | Version history | All users |
| `CONTRIBUTORS.md` | Contributors list | All users |
| `PROJECT_STRUCTURE.md` | This file | Developers |

### Configuration Files

| File | Description | Purpose |
|------|-------------|---------|
| `requirements.txt` | R package requirements | Package management |
| `setup.R` | Environment setup script | Automated setup |
| `environment.yml` | Conda environment | Conda package management |
| `Dockerfile` | Docker configuration | Container deployment |
| `docker-compose.yml` | Docker Compose | Multi-container deployment |

### GitHub Files

| File | Description | Purpose |
|------|-------------|---------|
| `.gitignore` | Git ignore rules | Version control |
| `.github/workflows/ci.yml` | CI/CD workflow | Automated testing |
| `.github/ISSUE_TEMPLATE/` | Issue templates | Issue management |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR template | Pull request management |

### Documentation Directory

| File | Description | Audience |
|------|-------------|----------|
| `docs/README.md` | Documentation index | All users |
| `docs/API.md` | API documentation | Developers |
| `docs/TROUBLESHOOTING.md` | Troubleshooting guide | All users |
| `docs/PERFORMANCE.md` | Performance guide | Advanced users |
| `docs/DEPLOYMENT.md` | Deployment guide | System administrators |

### Example Data

| File | Description | Purpose |
|------|-------------|---------|
| `example_data/README.md` | Example data documentation | All users |
| `example_data/cohortmrn_merge.data.csv` | Example cohort data | Testing |
| `example_data/OUTPT_LAB_RESULTS_LABS.csv` | Example lab results | Testing |
| `example_data/CANCER_DIAGNOSIS_CAREG.csv` | Example cancer diagnosis | Testing |

### Example Outputs (v2.0.0)

| File | Description | Purpose |
|------|-------------|---------|
| `example_outputs/README.md` | Example outputs documentation | All users |
| `example_outputs/lab_result_matrix.csv` | Standard wide format (deduplicated) | Demonstration |
| `example_outputs/lab_date_matrix.csv` | Standard wide format dates | Demonstration |
| `example_outputs/detailed_lab_results.csv` | Detailed results (deduplicated) | Demonstration |
| `example_outputs/lab_results_long_format.csv` | Long format (all data) | Demonstration |
| `example_outputs/lab_result_matrix_with_suffixes.csv` | Wide format with MRN suffixes | Demonstration |
| `example_outputs/lab_date_matrix_with_suffixes.csv` | Wide format dates with suffixes | Demonstration |
| `example_outputs/summary_statistics.csv` | Analysis summary | Demonstration |
| `example_outputs/lab_analysis_summary.txt` | Text summary report | Demonstration |

### Examples

| File | Description | Purpose |
|------|-------------|---------|
| `examples/README.md` | Examples documentation | All users |
| `examples/basic_usage.sh` | Basic usage examples | New users |
| `examples/advanced_config.sh` | Advanced configuration | Advanced users |

## Usage Patterns

### For New Users
1. Start with `README.md`
2. Use `example_data/` for testing
3. Run `examples/basic_usage.sh`
4. Refer to `docs/TROUBLESHOOTING.md` for issues

### For Developers
1. Read `CONTRIBUTING.md`
2. Check `docs/API.md` for technical details
3. Use `docs/PERFORMANCE.md` for optimization
4. Follow the development workflow

### For System Administrators
1. Review `docs/DEPLOYMENT.md`
2. Use `Dockerfile` and `docker-compose.yml`
3. Check `docs/PERFORMANCE.md` for system requirements
4. Set up monitoring and maintenance

### For Advanced Users
1. Use `examples/advanced_config.sh`
2. Refer to `docs/PERFORMANCE.md` for optimization
3. Check `docs/API.md` for advanced usage
4. Customize configuration as needed

## File Relationships

### Data Flow
```
Raw CSV Files → 01_data_preparation.R → RDS Files → 02_lab_analysis.R → Analysis Results
```

### Script Dependencies
```
run_analysis.sh → 01_data_preparation.R
run_analysis.sh → 02_lab_analysis.R
setup.R → requirements.txt
```

### Documentation Dependencies
```
README.md → All other documentation
docs/README.md → docs/*.md
examples/README.md → examples/*.sh
```

## Maintenance

### Regular Updates
- Update `CHANGELOG.md` for new versions
- Update `CONTRIBUTORS.md` for new contributors
- Update `README.md` for new features
- Update `docs/` for new documentation

### File Organization
- Keep related files together
- Use descriptive names
- Follow naming conventions
- Maintain directory structure

### Documentation
- Keep documentation up to date
- Use consistent formatting
- Include examples where helpful
- Cross-reference related topics

## Best Practices

### File Naming
- Use descriptive names
- Use consistent naming conventions
- Use appropriate file extensions
- Avoid special characters

### Directory Organization
- Group related files
- Use clear directory names
- Maintain logical hierarchy
- Keep structure simple

### Documentation
- Write for your audience
- Use clear, concise language
- Include practical examples
- Keep information current

### Code Organization
- Follow R style guidelines
- Use consistent formatting
- Add comments for complex code
- Keep functions focused

## Contributing

When contributing to the project:

1. **Follow the structure** - Maintain the existing organization
2. **Update documentation** - Keep docs in sync with code
3. **Use consistent naming** - Follow established conventions
4. **Test your changes** - Ensure everything works
5. **Update this file** - Document any structural changes

## Version Control

### Git Workflow
- Use feature branches for new features
- Keep commits focused and descriptive
- Use pull requests for code review
- Tag releases appropriately

### File Tracking
- Track all source code files
- Track configuration files
- Track documentation files
- Ignore temporary and output files

### Branching Strategy
- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - Feature branches
- `hotfix/*` - Hotfix branches

## Security

### Sensitive Files
- Never commit sensitive data
- Use environment variables for secrets
- Keep credentials secure
- Follow security best practices

### Data Privacy
- Handle clinical data carefully
- Follow privacy regulations
- Use secure storage
- Implement access controls

## Support

For questions about the project structure:

1. **Check the documentation** - Start with `README.md`
2. **Look at examples** - Use `examples/` directory
3. **Search issues** - Check GitHub issues
4. **Ask questions** - Use GitHub discussions
5. **Contact maintainers** - Follow contributing guidelines

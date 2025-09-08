# Troubleshooting Guide

This guide helps you resolve common issues when using the Clinical Lab Analysis Pipeline.

## Table of Contents

- [Common Issues](#common-issues)
- [Installation Problems](#installation-problems)
- [Data Issues](#data-issues)
- [Performance Issues](#performance-issues)
- [Memory Issues](#memory-issues)
- [Output Issues](#output-issues)
- [Error Messages](#error-messages)
- [Getting Help](#getting-help)

## Common Issues

### Issue: Permission Denied
**Error:** `Permission denied: ./run_analysis.sh`

**Solution:**
```bash
chmod +x run_analysis.sh
chmod +x examples/*.sh
```

### Issue: R Package Not Found
**Error:** `Error in library(data.table) : there is no package called 'data.table'`

**Solution:**
```r
# Install required packages
install.packages(c("data.table", "argparse"))

# Or use the setup script
Rscript setup.R
```

### Issue: Input File Not Found
**Error:** `Cohort file not found: /path/to/file.csv`

**Solution:**
1. Check file path and name
2. Ensure files are in the specified input directory
3. Verify file permissions
4. Check file extension (should be .csv)

### Issue: Date Format Problems
**Error:** `Error in as.Date() : character string is not in a standard unambiguous format`

**Solution:**
1. Ensure dates are in correct format:
   - Cohort data: `DD-MMM-YY` (e.g., "15-Jan-20")
   - Lab data: `YYYY-MM-DD` (e.g., "2020-01-15")
2. Check for special characters or encoding issues
3. Verify date column names

### Issue: Memory Allocation Error
**Error:** `Error: cannot allocate vector of size X Mb`

**Solution:**
1. Process fewer patients at a time
2. Increase system memory
3. Use `--n_patients` to limit processing
4. Close other applications to free memory

## Installation Problems

### Issue: R Not Found
**Error:** `Rscript not found`

**Solution:**
1. Install R from [CRAN](https://cran.r-project.org/)
2. Ensure R is in your PATH
3. Restart your terminal after installation

### Issue: Package Installation Fails
**Error:** `package installation failed`

**Solution:**
1. Check internet connection
2. Try different CRAN mirror:
   ```r
   options(repos = c(CRAN = "https://cran.rstudio.com/"))
   install.packages(c("data.table", "argparse"))
   ```
3. Install from source if needed:
   ```r
   install.packages(c("data.table", "argparse"), type = "source")
   ```

### Issue: Docker Build Fails
**Error:** `Docker build failed`

**Solution:**
1. Check Docker is running
2. Ensure Dockerfile is in the correct location
3. Try building without cache:
   ```bash
   docker build --no-cache -t clinical-lab-analysis .
   ```

## Data Issues

### Issue: Empty Output Files
**Problem:** Output files are created but empty

**Solution:**
1. Check input data format
2. Verify column names match requirements
3. Check for data type issues
4. Ensure data contains valid values

### Issue: Missing Lab Results
**Problem:** No lab results in output matrix

**Solution:**
1. Check if lab data exists for patients in cohort
2. Verify date formats in both datasets
3. Check date range overlap
4. Increase `--max_date_diff` parameter

### Issue: Incorrect Date Matching
**Problem:** Lab results don't match expected dates

**Solution:**
1. Check date formats in both datasets
2. Verify time zone settings
3. Check for date parsing issues
4. Review date difference calculations

### Issue: Column Name Problems
**Problem:** Unexpected column names in output

**Solution:**
1. Check input data column names
2. Verify column name format
3. Check for special characters
4. Review column filtering logic

## Performance Issues

### Issue: Slow Processing
**Problem:** Pipeline takes too long to run

**Solution:**
1. Process fewer patients at a time
2. Use RDS format for faster loading
3. Increase system memory
4. Use SSD storage for better I/O
5. Close other applications

### Issue: High Memory Usage
**Problem:** System runs out of memory

**Solution:**
1. Reduce number of patients
2. Process data in smaller chunks
3. Use `data.table` efficiently
4. Monitor memory usage
5. Consider using a machine with more RAM

### Issue: Disk Space Issues
**Problem:** Not enough disk space for output

**Solution:**
1. Check available disk space
2. Clean up temporary files
3. Use compression for output files
4. Consider using external storage

## Memory Issues

### Issue: Out of Memory Error
**Error:** `Error: cannot allocate vector of size X Mb`

**Solution:**
1. **Reduce dataset size:**
   ```bash
   ./run_analysis.sh full --input_dir data --n_patients 10
   ```

2. **Increase system memory:**
   - Add more RAM to your system
   - Use a machine with more memory

3. **Optimize memory usage:**
   - Close other applications
   - Use RDS format for faster loading
   - Process data in chunks

4. **Monitor memory usage:**
   ```r
   # Check memory usage
   memory.size()
   memory.limit()
   ```

### Issue: Memory Leaks
**Problem:** Memory usage increases over time

**Solution:**
1. Clear unused objects:
   ```r
   rm(list = ls())
   gc()
   ```

2. Use `data.table` efficiently
3. Avoid unnecessary data copying
4. Process data in smaller chunks

## Output Issues

### Issue: Missing Output Files
**Problem:** Expected output files are not created

**Solution:**
1. Check if output directory exists
2. Verify write permissions
3. Check for errors in the log
4. Ensure sufficient disk space

### Issue: Incorrect Output Format
**Problem:** Output files don't match expected format

**Solution:**
1. Check input data format
2. Verify column names
3. Check data types
4. Review processing logic

### Issue: Empty Output Files
**Problem:** Output files are created but empty

**Solution:**
1. Check input data quality
2. Verify data processing logic
3. Check for errors in the log
4. Ensure data contains valid values

## Error Messages

### Common Error Messages

#### `Error: cannot allocate vector of size X Mb`
**Cause:** Insufficient memory
**Solution:** Reduce dataset size or increase memory

#### `Error in as.Date() : character string is not in a standard unambiguous format`
**Cause:** Incorrect date format
**Solution:** Check date format and column names

#### `Error: file not found`
**Cause:** Missing input file
**Solution:** Check file path and existence

#### `Error: package not found`
**Cause:** Missing R package
**Solution:** Install required packages

#### `Error: permission denied`
**Cause:** Insufficient permissions
**Solution:** Check file permissions and ownership

### Debugging Tips

1. **Check the log output** for detailed error messages
2. **Use verbose mode** if available
3. **Test with small datasets** first
4. **Check system resources** (memory, disk space)
5. **Verify input data** format and content

## Getting Help

### Self-Help Resources

1. **Check the documentation:**
   - [Main README](../README.md)
   - [API Documentation](API.md)
   - [Examples](../examples/)

2. **Search existing issues:**
   - GitHub Issues
   - Discussion forums

3. **Test with example data:**
   - Use provided example data
   - Compare with working examples

### Reporting Issues

When reporting issues, please include:

1. **System information:**
   - Operating system
   - R version
   - Package versions
   - Available memory

2. **Error details:**
   - Complete error message
   - Steps to reproduce
   - Input data description

3. **Context:**
   - What you were trying to do
   - What you expected to happen
   - What actually happened

### Contact Information

- **GitHub Issues:** [Create an issue](https://github.com/your-username/clinical-lab-analysis-pipeline/issues)
- **Email:** [your-email@domain.com]
- **Documentation:** [Project documentation](../README.md)

## Prevention Tips

### Best Practices

1. **Always test with small datasets** first
2. **Use example data** to verify setup
3. **Check system requirements** before running
4. **Monitor resource usage** during processing
5. **Keep backups** of important data

### Regular Maintenance

1. **Update R packages** regularly
2. **Clean up temporary files** after processing
3. **Monitor disk space** usage
4. **Check for updates** to the pipeline
5. **Review logs** for potential issues

## Quick Reference

### Common Commands

```bash
# Check R version
R --version

# Install packages
Rscript -e "install.packages(c('data.table', 'argparse'))"

# Run setup
Rscript setup.R

# Test with example data
./run_analysis.sh full --input_dir example_data --n_patients 5

# Check memory usage
Rscript -e "memory.size(); memory.limit()"

# Check disk space
df -h

# Check file permissions
ls -la run_analysis.sh
```

### Emergency Recovery

If the pipeline fails completely:

1. **Stop the process** (Ctrl+C)
2. **Check system resources** (memory, disk space)
3. **Clean up temporary files**
4. **Restart with smaller dataset**
5. **Check logs** for error details
6. **Contact support** if needed

# Performance Guide

This guide provides tips and techniques for optimizing the performance of the Clinical Lab Analysis Pipeline.

## Table of Contents

- [Performance Overview](#performance-overview)
- [System Requirements](#system-requirements)
- [Memory Optimization](#memory-optimization)
- [Processing Optimization](#processing-optimization)
- [I/O Optimization](#io-optimization)
- [Parallel Processing](#parallel-processing)
- [Monitoring Performance](#monitoring-performance)
- [Benchmarking](#benchmarking)
- [Troubleshooting Performance](#troubleshooting-performance)

## Performance Overview

### Key Performance Factors

1. **Dataset Size** - Number of patients and lab records
2. **System Resources** - Memory, CPU, and storage
3. **Data Format** - CSV vs RDS format
4. **Processing Parameters** - Date windows, patient counts
5. **System Configuration** - R settings, OS optimization

### Performance Metrics

- **Processing Time** - Total time to complete analysis
- **Memory Usage** - Peak memory consumption
- **I/O Throughput** - Data reading/writing speed
- **CPU Utilization** - Processor usage efficiency

## System Requirements

### Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4GB | 8GB+ |
| CPU | 2 cores | 4+ cores |
| Storage | 10GB | 50GB+ |
| OS | Linux/macOS/Windows | Linux |

### Optimal Configuration

- **RAM:** 16GB+ for large datasets
- **CPU:** 8+ cores for parallel processing
- **Storage:** SSD for better I/O performance
- **OS:** Linux for best performance

## Memory Optimization

### Memory Usage Guidelines

| Dataset Size | Recommended RAM | Processing Time |
|--------------|-----------------|-----------------|
| < 1,000 patients | 4GB | < 5 minutes |
| 1,000-10,000 patients | 8GB | 5-30 minutes |
| 10,000-50,000 patients | 16GB | 30-120 minutes |
| > 50,000 patients | 32GB+ | 120+ minutes |

### Memory Optimization Techniques

#### 1. Process Data in Chunks
```bash
# Process in smaller batches
./run_analysis.sh full --input_dir data --n_patients 1000 --output_dir results_batch1
./run_analysis.sh full --input_dir data --n_patients 1000 --output_dir results_batch2
```

#### 2. Use RDS Format
```r
# RDS files are more memory efficient
saveRDS(data, "data.rds")
data <- readRDS("data.rds")
```

#### 3. Clear Unused Objects
```r
# Clear memory
rm(list = ls())
gc()
```

#### 4. Monitor Memory Usage
```r
# Check memory usage
memory.size()
memory.limit()

# Set memory limit
memory.limit(size = 8000)  # 8GB
```

### Memory-Efficient Data Processing

#### Use data.table Efficiently
```r
# Good: Use data.table operations
result <- data[condition, .(col1, col2), by = group]

# Bad: Avoid unnecessary copying
result <- data[condition, c("col1", "col2")]
```

#### Avoid Unnecessary Data Copying
```r
# Good: Modify in place
data[, new_col := old_col * 2]

# Bad: Create new objects
new_data <- data
new_data$new_col <- new_data$old_col * 2
```

## Processing Optimization

### Algorithm Optimization

#### 1. Optimize Date Matching
```r
# Use data.table for efficient date matching
setkey(lab_data, DFCI_MRN, SPECIMEN_COLLECT_DT)
result <- lab_data[cohort_data, on = "DFCI_MRN"]
```

#### 2. Use Efficient Data Types
```r
# Use appropriate data types
data[, date_col := as.Date(date_col)]
data[, numeric_col := as.numeric(numeric_col)]
```

#### 3. Minimize Data Movement
```r
# Process data in place when possible
data[, result := process_function(input)]
```

### Parameter Optimization

#### 1. Optimize Date Windows
```bash
# Use appropriate date windows
./run_analysis.sh full --input_dir data --max_date_diff 180  # 6 months
./run_analysis.sh full --input_dir data --max_date_diff 365  # 1 year
```

#### 2. Optimize Patient Counts
```bash
# Process appropriate number of patients
./run_analysis.sh full --input_dir data --n_patients 1000  # Good for testing
./run_analysis.sh full --input_dir data --n_patients all   # For production
```

#### 3. Optimize Column Filtering
```bash
# Remove unnecessary columns
./run_analysis.sh full --input_dir data --remove_digit_cols
```

## I/O Optimization

### File Format Optimization

#### Use RDS for Intermediate Files
```r
# RDS files are faster to read/write
saveRDS(data, "data.rds")
data <- readRDS("data.rds")
```

#### Use fread for CSV Files
```r
# fread is faster than read.csv
library(data.table)
data <- fread("data.csv")
```

### Storage Optimization

#### Use SSD Storage
- SSD provides better I/O performance
- Consider using SSD for temporary files
- Use SSD for output directories

#### Optimize File Organization
```bash
# Organize files efficiently
mkdir -p data/input
mkdir -p data/output
mkdir -p data/temp
```

### Network I/O Optimization

#### Use Local Storage
- Avoid network storage for large datasets
- Use local SSD for best performance
- Consider data locality

## Parallel Processing

### R Parallel Processing

#### 1. Use parallel Package
```r
library(parallel)

# Set up parallel processing
cl <- makeCluster(detectCores() - 1)

# Process data in parallel
result <- parLapply(cl, data_list, process_function)

# Clean up
stopCluster(cl)
```

#### 2. Use data.table Parallel Processing
```r
# data.table has built-in parallel processing
setDTthreads(0)  # Use all available cores
```

### System-Level Parallel Processing

#### 1. Process Multiple Batches
```bash
# Process multiple batches in parallel
./run_analysis.sh full --input_dir data --n_patients 1000 --output_dir batch1 &
./run_analysis.sh full --input_dir data --n_patients 1000 --output_dir batch2 &
wait
```

#### 2. Use GNU Parallel
```bash
# Install GNU parallel
sudo apt-get install parallel

# Process in parallel
parallel -j 4 ./run_analysis.sh full --input_dir data --n_patients 1000 --output_dir batch{} ::: {1..4}
```

## Monitoring Performance

### R Performance Monitoring

#### 1. Use Rprof for Profiling
```r
# Start profiling
Rprof("profile.out")

# Run your code
result <- perform_lab_analysis(args, n_patients)

# Stop profiling
Rprof(NULL)

# View results
summaryRprof("profile.out")
```

#### 2. Monitor Memory Usage
```r
# Check memory usage
memory.size()
memory.limit()

# Monitor during execution
while(TRUE) {
  cat("Memory usage:", memory.size(), "MB\n")
  Sys.sleep(1)
}
```

#### 3. Use system.time
```r
# Time your code
system.time({
  result <- perform_lab_analysis(args, n_patients)
})
```

### System Performance Monitoring

#### 1. Monitor CPU Usage
```bash
# Monitor CPU usage
top -p $(pgrep -f "Rscript")
```

#### 2. Monitor Memory Usage
```bash
# Monitor memory usage
free -h
ps aux | grep Rscript
```

#### 3. Monitor I/O Usage
```bash
# Monitor I/O usage
iostat -x 1
```

## Benchmarking

### Performance Benchmarks

#### 1. Dataset Size Benchmarks
```bash
# Test with different dataset sizes
for size in 100 500 1000 5000 10000; do
  echo "Testing with $size patients..."
  time ./run_analysis.sh full --input_dir data --n_patients $size --output_dir benchmark_$size
done
```

#### 2. Memory Usage Benchmarks
```bash
# Monitor memory usage during processing
while true; do
  ps aux | grep Rscript | awk '{print $6}' | sort -n | tail -1
  sleep 1
done
```

#### 3. I/O Performance Benchmarks
```bash
# Test I/O performance
dd if=/dev/zero of=test_file bs=1M count=1000
time dd if=test_file of=/dev/null bs=1M
rm test_file
```

### Benchmarking Scripts

#### Create Performance Test Script
```bash
#!/bin/bash
# performance_test.sh

echo "Performance Test Results"
echo "========================"

# Test different patient counts
for patients in 100 500 1000 2000 5000; do
  echo "Testing $patients patients..."
  
  # Measure time
  start_time=$(date +%s)
  ./run_analysis.sh full --input_dir data --n_patients $patients --output_dir test_$patients
  end_time=$(date +%s)
  
  # Calculate duration
  duration=$((end_time - start_time))
  echo "  Duration: $duration seconds"
  
  # Measure memory usage
  peak_memory=$(ps aux | grep Rscript | awk '{print $6}' | sort -n | tail -1)
  echo "  Peak memory: $peak_memory KB"
  
  echo ""
done
```

## Troubleshooting Performance

### Common Performance Issues

#### 1. Slow Processing
**Symptoms:** Pipeline takes too long to complete
**Solutions:**
- Reduce number of patients
- Use RDS format
- Increase system memory
- Use SSD storage
- Close other applications

#### 2. High Memory Usage
**Symptoms:** System runs out of memory
**Solutions:**
- Process data in smaller chunks
- Use memory-efficient data types
- Clear unused objects
- Increase system memory

#### 3. Slow I/O
**Symptoms:** Reading/writing files is slow
**Solutions:**
- Use SSD storage
- Use RDS format
- Optimize file organization
- Use local storage

#### 4. CPU Bottlenecks
**Symptoms:** High CPU usage, slow processing
**Solutions:**
- Use parallel processing
- Optimize algorithms
- Use data.table efficiently
- Increase CPU cores

### Performance Debugging

#### 1. Identify Bottlenecks
```r
# Use Rprof to identify bottlenecks
Rprof("profile.out")
# Your code here
Rprof(NULL)
summaryRprof("profile.out")
```

#### 2. Monitor Resource Usage
```bash
# Monitor system resources
htop
iostat -x 1
free -h
```

#### 3. Profile Memory Usage
```r
# Profile memory usage
library(profmem)
result <- profmem({
  # Your code here
})
print(result)
```

## Best Practices

### General Performance Tips

1. **Start Small:** Always test with small datasets first
2. **Monitor Resources:** Keep an eye on memory and CPU usage
3. **Use Appropriate Formats:** RDS for intermediate files, CSV for final output
4. **Optimize Parameters:** Use appropriate date windows and patient counts
5. **Clean Up:** Remove temporary files and clear memory

### Development Workflow

1. **Test with Example Data:** Use provided example data for testing
2. **Profile Your Code:** Use Rprof to identify bottlenecks
3. **Monitor Performance:** Track memory and CPU usage
4. **Optimize Incrementally:** Make small improvements and test
5. **Document Changes:** Keep track of performance improvements

### Production Deployment

1. **Use Appropriate Hardware:** Ensure sufficient memory and CPU
2. **Optimize Storage:** Use SSD for better I/O performance
3. **Monitor Performance:** Set up monitoring and alerting
4. **Plan for Scale:** Consider how to handle larger datasets
5. **Backup Data:** Ensure data is backed up regularly

## Performance Checklist

### Before Running
- [ ] Check system requirements
- [ ] Verify data format and quality
- [ ] Test with small dataset
- [ ] Check available resources
- [ ] Plan for data backup

### During Processing
- [ ] Monitor memory usage
- [ ] Check CPU utilization
- [ ] Monitor disk I/O
- [ ] Watch for errors
- [ ] Log performance metrics

### After Processing
- [ ] Verify output files
- [ ] Check processing time
- [ ] Review resource usage
- [ ] Clean up temporary files
- [ ] Document performance results

# Usage Examples

This directory contains comprehensive examples demonstrating how to use the Clinical Lab Analysis Pipeline.

## Examples

### 1. Basic Usage (`basic_usage.sh`)
Demonstrates the most common usage patterns:
- Running the complete pipeline
- Processing different numbers of patients
- Using custom output directories

### 2. Advanced Configuration (`advanced_config.sh`)
Shows advanced configuration options:
- Custom date windows
- Different processing parameters
- Batch processing

### 3. Step-by-Step Processing (`step_by_step.sh`)
Demonstrates running individual pipeline steps:
- Data preparation only
- Lab analysis only
- Custom intermediate steps

### 4. Error Handling (`error_handling.sh`)
Shows how to handle common errors and edge cases:
- Missing files
- Invalid data formats
- Memory issues

### 5. Performance Testing (`performance_test.sh`)
Demonstrates performance testing with different dataset sizes:
- Small datasets (testing)
- Medium datasets (development)
- Large datasets (production)

## Running Examples

### Quick Start
```bash
# Make examples executable
chmod +x examples/*.sh

# Run basic usage example
./examples/basic_usage.sh

# Run advanced configuration example
./examples/advanced_config.sh
```

### Prerequisites
- R with required packages installed
- Example data files in `example_data/` directory
- Pipeline scripts in the root directory

## Example Descriptions

### Basic Usage Example
```bash
#!/bin/bash
# Basic usage examples

echo "=== Basic Usage Examples ==="

# Example 1: Run complete pipeline with 5 patients
echo "1. Running complete pipeline with 5 patients..."
./run_analysis.sh full --input_dir example_data --n_patients 5

# Example 2: Run with all patients
echo "2. Running with all patients..."
./run_analysis.sh full --input_dir example_data --n_patients all

# Example 3: Custom output directory
echo "3. Running with custom output directory..."
./run_analysis.sh full --input_dir example_data --output_dir ./custom_results --n_patients 10
```

### Advanced Configuration Example
```bash
#!/bin/bash
# Advanced configuration examples

echo "=== Advanced Configuration Examples ==="

# Example 1: Custom date window
echo "1. Running with 6-month date window..."
./run_analysis.sh full --input_dir example_data --n_patients 20 --max_date_diff 180

# Example 2: Keep digit columns
echo "2. Running without removing digit columns..."
./run_analysis.sh full --input_dir example_data --n_patients 15 --no_remove_digits

# Example 3: Step-by-step processing
echo "3. Step-by-step processing..."
./run_analysis.sh prepare --input_dir example_data --output_dir ./step1_output
./run_analysis.sh analyze --input_dir ./step1_output --n_patients 25 --output_dir ./step2_output
```

## Customization

### Modifying Examples
You can modify the examples to suit your needs:

1. **Change input directory**: Update `--input_dir` parameter
2. **Change number of patients**: Update `--n_patients` parameter
3. **Change output directory**: Update `--output_dir` parameter
4. **Add custom parameters**: Add additional command-line options

### Creating New Examples
To create new examples:

1. **Create a new script file**: `examples/your_example.sh`
2. **Make it executable**: `chmod +x examples/your_example.sh`
3. **Add shebang**: `#!/bin/bash`
4. **Add your commands**: Follow the pattern of existing examples
5. **Add documentation**: Update this README

## Troubleshooting Examples

### Common Issues
- **Permission denied**: Run `chmod +x examples/*.sh`
- **File not found**: Check that example data files exist
- **R package missing**: Run `Rscript setup.R`
- **Memory issues**: Reduce number of patients

### Getting Help
- Check the main README.md for detailed documentation
- Look at the error messages for specific issues
- Use `--help` flag with any script for usage information

## Best Practices

### Testing
- Always test with small datasets first
- Use example data before real data
- Verify output files and formats

### Performance
- Monitor memory usage with large datasets
- Use appropriate number of patients for your system
- Consider processing in batches for very large datasets

### Data Management
- Keep input and output directories organized
- Use descriptive output directory names
- Clean up temporary files regularly

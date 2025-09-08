# Contributing to Clinical Lab Analysis Pipeline

Thank you for your interest in contributing to the Clinical Lab Analysis Pipeline! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Check the documentation** to ensure it's not a usage question
3. **Provide detailed information** about the problem

When creating an issue, please include:

- **Clear description** of the problem
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **System information** (OS, R version, etc.)
- **Sample data** (if applicable and not sensitive)

### Suggesting Features

We welcome feature suggestions! Please:

1. **Check existing issues** for similar requests
2. **Describe the use case** clearly
3. **Explain the expected benefit**
4. **Consider implementation complexity**

### Code Contributions

#### Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/clinical-lab-analysis-pipeline.git
   cd clinical-lab-analysis-pipeline
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Set up development environment**:
   ```bash
   # Install R packages
   Rscript setup.R
   
   # Or use conda
   conda env create -f environment.yml
   conda activate clinical-lab-analysis
   ```

#### Development Guidelines

##### Code Style

- **Follow R style guidelines** (use `styler` package)
- **Use meaningful variable names**
- **Add comments** for complex logic
- **Keep functions focused** and small
- **Use consistent indentation** (2 spaces)

##### Documentation

- **Update README.md** for user-facing changes
- **Add inline comments** for complex code
- **Update help text** in argument parsers
- **Document new functions** with roxygen2-style comments

##### Testing

- **Test with small datasets** first
- **Verify output format** and content
- **Test error handling** with invalid inputs
- **Check memory usage** with large datasets

##### Example Development Workflow

```bash
# 1. Make your changes
vim 01_data_preparation.R

# 2. Test your changes
./run_analysis.sh full --input_dir test_data --n_patients 5

# 3. Check for issues
Rscript -e "library(styler); style_file('01_data_preparation.R')"

# 4. Commit changes
git add .
git commit -m "Add feature: improved error handling"

# 5. Push to your fork
git push origin feature/your-feature-name
```

#### Pull Request Process

1. **Ensure your code works**:
   ```bash
   # Test the complete pipeline
   ./run_analysis.sh full --input_dir test_data --n_patients 5
   
   # Test individual components
   Rscript 01_data_preparation.R --input_dir test_data
   Rscript 02_lab_analysis.R --input_dir prepared_data --n_patients 5
   ```

2. **Update documentation** if needed

3. **Create a pull request** with:
   - **Clear title** describing the change
   - **Detailed description** of what was changed
   - **Reference to related issues**
   - **Screenshots** if UI changes were made

4. **Respond to feedback** and make requested changes

## 📋 Development Standards

### Code Quality

- **No hardcoded paths** - use command line arguments
- **Handle errors gracefully** - provide meaningful error messages
- **Validate inputs** - check file existence, data format, etc.
- **Use consistent naming** - follow R conventions
- **Optimize for performance** - use `data.table` efficiently

### Documentation Standards

- **Update README.md** for user-facing changes
- **Add examples** for new features
- **Document all parameters** in help text
- **Include troubleshooting** information

### Testing Standards

- **Test with various data sizes** (small, medium, large)
- **Test error conditions** (missing files, invalid data)
- **Verify output format** and content
- **Check memory usage** and performance

## 🐛 Bug Reports

When reporting bugs, please include:

### Required Information

- **R version**: `R.version.string`
- **Package versions**: `packageVersion("data.table")`
- **Operating system**: `Sys.info()["sysname"]`
- **Error message**: Complete error output
- **Steps to reproduce**: Detailed steps

### Optional Information

- **Sample data**: If possible and not sensitive
- **Expected output**: What should happen
- **Actual output**: What actually happens
- **Screenshots**: If applicable

### Bug Report Template

```markdown
**Bug Description**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. See error '...'

**Expected Behavior**
What you expected to happen.

**System Information**
- R version: [e.g., R version 4.2.0]
- OS: [e.g., Ubuntu 20.04]
- Package versions: [e.g., data.table 1.14.0]

**Additional Context**
Any other context about the problem.
```

## 🚀 Feature Requests

When suggesting features, please include:

### Required Information

- **Use case**: Why is this feature needed?
- **Expected behavior**: How should it work?
- **Alternatives**: What have you tried instead?

### Optional Information

- **Mockups**: Visual representations if applicable
- **Implementation ideas**: If you have suggestions
- **Priority**: How important is this feature?

### Feature Request Template

```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Use Case**
Why is this feature needed? What problem does it solve?

**Proposed Solution**
How should this feature work?

**Alternatives**
What alternatives have you considered?

**Additional Context**
Any other context about the feature request.
```

## 📚 Development Resources

### R Resources

- [R Style Guide](https://style.tidyverse.org/)
- [data.table Documentation](https://rdatatable.gitlab.io/data.table/)
- [argparse Documentation](https://cran.r-project.org/web/packages/argparse/argparse.pdf)

### Git Resources

- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Pull Request Best Practices](https://github.com/blog/1943-how-to-write-the-perfect-pull-request)

### Testing Resources

- [R Testing](https://r-pkgs.org/testing-basics.html)
- [Unit Testing in R](https://testthat.r-lib.org/)

## 🏷️ Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Release notes prepared
- [ ] Tag created

## 📞 Getting Help

### Community Support

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For general questions and discussions
- **Email**: [your-email@domain.com] for direct contact

### Development Support

- **Code reviews**: Available for pull requests
- **Mentoring**: Available for new contributors
- **Documentation**: Comprehensive guides available

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Recognition

Contributors will be recognized in:

- **CONTRIBUTORS.md**: List of all contributors
- **Release notes**: For significant contributions
- **README.md**: For major contributors

Thank you for contributing to the Clinical Lab Analysis Pipeline! 🎉

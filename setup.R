#!/usr/bin/env Rscript

# =============================================================================
# ENVIRONMENT SETUP SCRIPT
# =============================================================================
# This script sets up the R environment for the clinical lab analysis pipeline.
# It installs required packages and checks system requirements.
#
# Usage: Rscript setup.R [options]
#
# Options:
#   --install_packages    Install required packages (default: TRUE)
#   --check_system        Check system requirements (default: TRUE)
#   --update_packages     Update existing packages (default: FALSE)
#   --help, -h            Show this help message
#
# Examples:
#   # Basic setup
#   Rscript setup.R
#
#   # Skip package installation
#   Rscript setup.R --install_packages FALSE
#
#   # Update existing packages
#   Rscript setup.R --update_packages TRUE
#
# =============================================================================

# Load required libraries
suppressPackageStartupMessages({
  if (!require(argparse, quietly = TRUE)) {
    cat("Installing argparse package...\n")
    install.packages("argparse", repos = "https://cran.r-project.org/")
    library(argparse)
  }
})

# =============================================================================
# COMMAND LINE ARGUMENT PARSING
# =============================================================================

create_parser <- function() {
  parser <- ArgumentParser(
    description = "Environment Setup Script for Clinical Lab Analysis Pipeline",
    formatter_class = "argparse.RawDescriptionHelpFormatter",
    epilog = "
EXAMPLES:
  # Basic setup
  Rscript setup.R
  
  # Skip package installation
  Rscript setup.R --install_packages FALSE
  
  # Update existing packages
  Rscript setup.R --update_packages TRUE
  
  # Check system only
  Rscript setup.R --install_packages FALSE --check_system TRUE
"
  )
  
  parser$add_argument("--install_packages", 
                     action = "store_true",
                     default = TRUE,
                     help = "Install required packages (default: %(default)s)")
  
  parser$add_argument("--check_system", 
                     action = "store_true",
                     default = TRUE,
                     help = "Check system requirements (default: %(default)s)")
  
  parser$add_argument("--update_packages", 
                     action = "store_true",
                     default = FALSE,
                     help = "Update existing packages (default: %(default)s)")
  
  return(parser)
}

# Parse arguments
args <- create_parser()$parse_args()

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

print_header <- function(message) {
  cat(paste(rep("=", 60), collapse = ""), "\n")
  cat(message, "\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
}

print_success <- function(message) {
  cat("✓", message, "\n")
}

print_warning <- function(message) {
  cat("⚠", message, "\n")
}

print_error <- function(message) {
  cat("✗", message, "\n")
}

# =============================================================================
# SYSTEM REQUIREMENTS CHECK
# =============================================================================

check_system_requirements <- function() {
  print_header("CHECKING SYSTEM REQUIREMENTS")
  
  # Check R version
  r_version <- R.version.string
  cat("R version:", r_version, "\n")
  
  # Check if R version is sufficient (3.6+)
  r_version_numeric <- as.numeric(paste(R.version$major, R.version$minor, sep = "."))
  if (r_version_numeric >= 3.6) {
    print_success("R version is sufficient (3.6+)")
  } else {
    print_error("R version is too old. Please upgrade to R 3.6 or higher.")
    return(FALSE)
  }
  
  # Check available memory
  if (.Platform$OS.type == "unix") {
    memory_info <- system("free -h", intern = TRUE)
    cat("Memory information:\n")
    cat(paste(memory_info, collapse = "\n"), "\n")
  } else {
    cat("Memory check not available on this platform\n")
  }
  
  # Check available disk space
  if (.Platform$OS.type == "unix") {
    disk_info <- system("df -h .", intern = TRUE)
    cat("Disk space information:\n")
    cat(paste(disk_info, collapse = "\n"), "\n")
  } else {
    cat("Disk space check not available on this platform\n")
  }
  
  # Check if required directories exist
  current_dir <- getwd()
  cat("Current working directory:", current_dir, "\n")
  
  if (dir.exists(current_dir)) {
    print_success("Working directory is accessible")
  } else {
    print_error("Working directory is not accessible")
    return(FALSE)
  }
  
  print_success("System requirements check completed")
  return(TRUE)
}

# =============================================================================
# PACKAGE INSTALLATION
# =============================================================================

install_required_packages <- function(update_packages = FALSE) {
  print_header("INSTALLING REQUIRED PACKAGES")
  
  # Required packages
  required_packages <- c("data.table", "argparse")
  
  # Optional packages (commented out by default)
  optional_packages <- c(
    "lubridate",    # Better date handling
    "progress",     # Progress bars
    "parallel",     # Parallel processing
    "pryr",         # Memory profiling
    "validate"      # Data validation
  )
  
  # Function to install package
  install_package <- function(pkg) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat("Installing", pkg, "...\n")
      install.packages(pkg, repos = "https://cran.r-project.org/", dependencies = TRUE)
      
      # Check if installation was successful
      if (require(pkg, character.only = TRUE, quietly = TRUE)) {
        print_success(paste("Successfully installed", pkg))
        return(TRUE)
      } else {
        print_error(paste("Failed to install", pkg))
        return(FALSE)
      }
    } else {
      print_success(paste(pkg, "is already installed"))
      return(TRUE)
    }
  }
  
  # Install required packages
  cat("Installing required packages...\n")
  required_success <- sapply(required_packages, install_package)
  
  if (all(required_success)) {
    print_success("All required packages installed successfully")
  } else {
    print_error("Some required packages failed to install")
    return(FALSE)
  }
  
  # Update packages if requested
  if (update_packages) {
    print_header("UPDATING PACKAGES")
    cat("Updating all packages...\n")
    update.packages(ask = FALSE, repos = "https://cran.r-project.org/")
    print_success("Package update completed")
  }
  
  # Show package versions
  print_header("PACKAGE VERSIONS")
  for (pkg in required_packages) {
    if (require(pkg, character.only = TRUE, quietly = TRUE)) {
      version <- packageVersion(pkg)
      cat(pkg, ":", as.character(version), "\n")
    }
  }
  
  return(TRUE)
}

# =============================================================================
# VERIFICATION
# =============================================================================

verify_installation <- function() {
  print_header("VERIFYING INSTALLATION")
  
  # Test loading required packages
  required_packages <- c("data.table", "argparse")
  
  for (pkg in required_packages) {
    if (require(pkg, character.only = TRUE, quietly = TRUE)) {
      print_success(paste("Package", pkg, "loads successfully"))
    } else {
      print_error(paste("Package", pkg, "failed to load"))
      return(FALSE)
    }
  }
  
  # Test basic functionality
  cat("Testing basic functionality...\n")
  
  # Test data.table
  tryCatch({
    dt <- data.table(a = 1:5, b = letters[1:5])
    if (nrow(dt) == 5) {
      print_success("data.table functionality test passed")
    } else {
      print_error("data.table functionality test failed")
      return(FALSE)
    }
  }, error = function(e) {
    print_error(paste("data.table test error:", e$message))
    return(FALSE)
  })
  
  # Test argparse
  tryCatch({
    parser <- ArgumentParser(description = "Test parser")
    parser$add_argument("--test", default = "test")
    args <- parser$parse_args()
    if (args$test == "test") {
      print_success("argparse functionality test passed")
    } else {
      print_error("argparse functionality test failed")
      return(FALSE)
    }
  }, error = function(e) {
    print_error(paste("argparse test error:", e$message))
    return(FALSE)
  })
  
  print_success("All verification tests passed")
  return(TRUE)
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main <- function() {
  start_time <- Sys.time()
  
  cat("Clinical Lab Analysis Pipeline - Environment Setup\n")
  cat("==================================================\n")
  cat("Start time:", format(start_time), "\n\n")
  
  success <- TRUE
  
  # Check system requirements
  if (args$check_system) {
    if (!check_system_requirements()) {
      success <- FALSE
    }
  }
  
  # Install packages
  if (args$install_packages && success) {
    if (!install_required_packages(args$update_packages)) {
      success <- FALSE
    }
  }
  
  # Verify installation
  if (success) {
    if (!verify_installation()) {
      success <- FALSE
    }
  }
  
  # Final summary
  end_time <- Sys.time()
  processing_time <- round(as.numeric(end_time - start_time, units = "secs"), 2)
  
  print_header("SETUP SUMMARY")
  cat("Setup completed:", format(end_time), "\n")
  cat("Processing time:", processing_time, "seconds\n")
  
  if (success) {
    print_success("Environment setup completed successfully!")
    print_success("You can now run the clinical lab analysis pipeline.")
    cat("\nNext steps:\n")
    cat("1. Prepare your data files\n")
    cat("2. Run: ./run_analysis.sh full --input_dir /path/to/data --n_patients 5\n")
  } else {
    print_error("Environment setup failed!")
    print_error("Please check the error messages above and try again.")
    quit(status = 1)
  }
  
  return(success)
}

# Run main function
if (!interactive()) {
  tryCatch({
    success <- main()
    quit(status = ifelse(success, 0, 1))
  }, error = function(e) {
    print_error(paste("Setup error:", e$message))
    quit(status = 1)
  })
}

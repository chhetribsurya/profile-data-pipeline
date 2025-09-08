# Dockerfile for Clinical Lab Analysis Pipeline
# 
# This Dockerfile creates a containerized environment for running the
# clinical lab analysis pipeline.
#
# Build: docker build -t clinical-lab-analysis .
# Run: docker run -v /path/to/data:/data clinical-lab-analysis

FROM rocker/r-ver:4.2.0

# Set maintainer
LABEL maintainer="your-email@domain.com"
LABEL description="Clinical Lab Analysis Pipeline for DFCI Research"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('data.table', 'argparse'), repos='https://cran.r-project.org/')"

# Optional: Install additional packages for enhanced functionality
RUN R -e "install.packages(c('lubridate', 'progress', 'parallel', 'pryr', 'validate'), repos='https://cran.r-project.org/')"

# Copy pipeline files
COPY . /app/

# Make scripts executable
RUN chmod +x run_analysis.sh
RUN chmod +x setup.R

# Create data directories
RUN mkdir -p /data/input /data/output

# Set environment variables
ENV R_LIBS_USER=/usr/local/lib/R/site-library
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Expose port (if needed for web interface)
# EXPOSE 8080

# Default command
CMD ["bash", "-c", "echo 'Clinical Lab Analysis Pipeline is ready!' && echo 'Usage: ./run_analysis.sh full --input_dir /data/input --n_patients 5' && bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD R -e "library(data.table); library(argparse)" || exit 1

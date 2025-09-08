# Deployment Guide

This guide covers different deployment options for the Clinical Lab Analysis Pipeline.

## Table of Contents

- [Deployment Overview](#deployment-overview)
- [Local Deployment](#local-deployment)
- [Docker Deployment](#docker-deployment)
- [Cloud Deployment](#cloud-deployment)
- [Cluster Deployment](#cluster-deployment)
- [Production Deployment](#production-deployment)
- [Monitoring and Maintenance](#monitoring-and-maintenance)

## Deployment Overview

### Deployment Options

1. **Local Deployment** - Single machine setup
2. **Docker Deployment** - Containerized deployment
3. **Cloud Deployment** - Cloud platform deployment
4. **Cluster Deployment** - Multi-node cluster setup
5. **Production Deployment** - Enterprise production setup

### Deployment Considerations

- **Data Security** - Ensure data privacy and security
- **Scalability** - Handle varying workloads
- **Reliability** - Ensure system availability
- **Performance** - Optimize for speed and efficiency
- **Maintenance** - Easy updates and monitoring

## Local Deployment

### Prerequisites

- R (version 3.6 or higher)
- Required R packages
- Sufficient system resources
- Data files in correct format

### Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/chhetribsurya/profile-data-pipeline.git
cd profile-data-pipeline
```

#### 2. Install Dependencies
```bash
# Install R packages
Rscript setup.R

# Or install manually
Rscript -e "install.packages(c('data.table', 'argparse'))"
```

#### 3. Make Scripts Executable
```bash
chmod +x run_analysis.sh
chmod +x examples/*.sh
```

#### 4. Test Installation
```bash
# Test with example data
./run_analysis.sh full --input_dir example_data --n_patients 5
```

### Configuration

#### Environment Variables
```bash
# Set R options
export R_LIBS_USER="/path/to/r/packages"
export R_MAX_MEMORY="8GB"

# Set pipeline options
export PIPELINE_INPUT_DIR="/path/to/input"
export PIPELINE_OUTPUT_DIR="/path/to/output"
```

#### R Configuration
```r
# .Rprofile
options(repos = c(CRAN = "https://cran.r-project.org/"))
options(max.memory = 8000)  # 8GB
```

## Docker Deployment

### Prerequisites

- Docker installed
- Docker Compose (optional)
- Sufficient system resources

### Basic Docker Deployment

#### 1. Build Docker Image
```bash
# Build the image
docker build -t clinical-lab-analysis .

# Or use docker-compose
docker-compose build
```

#### 2. Run Container
```bash
# Run with data volume
docker run -v /path/to/data:/data -v /path/to/output:/app/output clinical-lab-analysis

# Or use docker-compose
docker-compose up
```

#### 3. Execute Pipeline
```bash
# Run pipeline in container
docker exec -it clinical-lab-analysis ./run_analysis.sh full --input_dir /data --n_patients 10
```

### Advanced Docker Deployment

#### Custom Dockerfile
```dockerfile
FROM rocker/r-ver:4.2.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    git \
    vim

# Install R packages
RUN R -e "install.packages(c('data.table', 'argparse'), repos='https://cran.r-project.org/')"

# Copy pipeline files
COPY . /app/
WORKDIR /app

# Make scripts executable
RUN chmod +x run_analysis.sh

# Set environment variables
ENV R_LIBS_USER=/usr/local/lib/R/site-library
ENV LANG=C.UTF-8

# Default command
CMD ["bash"]
```

#### Docker Compose Configuration
```yaml
version: '3.8'

services:
  app:
    build: .
    volumes:
      - ./data:/data
      - ./output:/app/output
    environment:
      - R_LIBS_USER=/usr/local/lib/R/site-library
    working_dir: /app
    command: bash

  rstudio:
    image: rocker/rstudio:4.2.0
    ports:
      - "8787:8787"
    volumes:
      - ./data:/data
      - ./output:/app/output
    environment:
      - PASSWORD=your_password
```

### Docker Best Practices

#### 1. Use Multi-stage Builds
```dockerfile
# Build stage
FROM rocker/r-ver:4.2.0 as builder
RUN R -e "install.packages(c('data.table', 'argparse'))"

# Runtime stage
FROM rocker/r-ver:4.2.0
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY . /app/
WORKDIR /app
```

#### 2. Optimize Image Size
```dockerfile
# Use minimal base image
FROM rocker/r-ver:4.2.0

# Clean up after installation
RUN apt-get update && apt-get install -y \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('data.table', 'argparse'))" \
    && rm -rf /tmp/downloaded_packages
```

#### 3. Use Health Checks
```dockerfile
# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD R -e "library(data.table); library(argparse)" || exit 1
```

## Cloud Deployment

### AWS Deployment

#### 1. EC2 Instance Setup
```bash
# Launch EC2 instance
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t3.large \
    --key-name your-key-pair \
    --security-group-ids sg-12345678

# Connect to instance
ssh -i your-key-pair.pem ec2-user@your-instance-ip
```

#### 2. Install Dependencies
```bash
# Install R
sudo yum update -y
sudo yum install -y R

# Install R packages
sudo R -e "install.packages(c('data.table', 'argparse'), repos='https://cran.r-project.org/')"
```

#### 3. Deploy Pipeline
```bash
# Clone repository
git clone https://github.com/your-username/clinical-lab-analysis-pipeline.git
cd clinical-lab-analysis-pipeline

# Make scripts executable
chmod +x run_analysis.sh

# Run pipeline
./run_analysis.sh full --input_dir /data --n_patients 1000
```

#### 4. Use S3 for Data Storage
```bash
# Upload data to S3
aws s3 cp /path/to/data s3://your-bucket/data/ --recursive

# Download data from S3
aws s3 cp s3://your-bucket/data/ /path/to/data/ --recursive

# Upload results to S3
aws s3 cp /path/to/results s3://your-bucket/results/ --recursive
```

### Google Cloud Deployment

#### 1. Compute Engine Setup
```bash
# Create instance
gcloud compute instances create pipeline-instance \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-4 \
    --zone us-central1-a

# Connect to instance
gcloud compute ssh pipeline-instance --zone us-central1-a
```

#### 2. Install Dependencies
```bash
# Install R
sudo apt-get update
sudo apt-get install -y r-base

# Install R packages
sudo R -e "install.packages(c('data.table', 'argparse'), repos='https://cran.r-project.org/')"
```

#### 3. Use Cloud Storage
```bash
# Upload data to Cloud Storage
gsutil cp -r /path/to/data gs://your-bucket/data/

# Download data from Cloud Storage
gsutil cp -r gs://your-bucket/data/ /path/to/data/

# Upload results to Cloud Storage
gsutil cp -r /path/to/results gs://your-bucket/results/
```

### Azure Deployment

#### 1. Virtual Machine Setup
```bash
# Create VM
az vm create \
    --resource-group myResourceGroup \
    --name pipeline-vm \
    --image UbuntuLTS \
    --size Standard_D2s_v3 \
    --admin-username azureuser \
    --generate-ssh-keys

# Connect to VM
ssh azureuser@your-vm-ip
```

#### 2. Install Dependencies
```bash
# Install R
sudo apt-get update
sudo apt-get install -y r-base

# Install R packages
sudo R -e "install.packages(c('data.table', 'argparse'), repos='https://cran.r-project.org/')"
```

#### 3. Use Blob Storage
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Upload data to Blob Storage
az storage blob upload-batch \
    --destination data \
    --source /path/to/data \
    --account-name yourstorageaccount

# Download data from Blob Storage
az storage blob download-batch \
    --destination /path/to/data \
    --source data \
    --account-name yourstorageaccount
```

## Cluster Deployment

### Slurm Cluster

#### 1. Job Script
```bash
#!/bin/bash
#SBATCH --job-name=lab-analysis
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=lab_analysis_%j.out
#SBATCH --error=lab_analysis_%j.err

# Load modules
module load R/4.2.0

# Set environment variables
export R_LIBS_USER=$HOME/R/packages
export OMP_NUM_THREADS=8

# Run pipeline
cd $SLURM_SUBMIT_DIR
./run_analysis.sh full --input_dir /data --n_patients 10000 --output_dir /results
```

#### 2. Submit Job
```bash
# Submit job
sbatch job_script.sh

# Check job status
squeue -u $USER

# Cancel job
scancel job_id
```

### Kubernetes Deployment

#### 1. Deployment YAML
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-analysis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lab-analysis
  template:
    metadata:
      labels:
        app: lab-analysis
    spec:
      containers:
      - name: lab-analysis
        image: clinical-lab-analysis:latest
        resources:
          requests:
            memory: "8Gi"
            cpu: "2"
          limits:
            memory: "16Gi"
            cpu: "4"
        volumeMounts:
        - name: data-volume
          mountPath: /data
        - name: output-volume
          mountPath: /app/output
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: data-pvc
      - name: output-volume
        persistentVolumeClaim:
          claimName: output-pvc
```

#### 2. Service YAML
```yaml
apiVersion: v1
kind: Service
metadata:
  name: lab-analysis-service
spec:
  selector:
    app: lab-analysis
  ports:
  - port: 8080
    targetPort: 8080
  type: LoadBalancer
```

#### 3. Deploy to Kubernetes
```bash
# Apply configurations
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check status
kubectl get pods
kubectl get services

# Execute pipeline
kubectl exec -it deployment/lab-analysis -- ./run_analysis.sh full --input_dir /data --n_patients 1000
```

## Production Deployment

### Production Checklist

#### Infrastructure
- [ ] Sufficient compute resources
- [ ] High availability setup
- [ ] Data backup and recovery
- [ ] Security measures
- [ ] Monitoring and alerting

#### Application
- [ ] Code review and testing
- [ ] Performance optimization
- [ ] Error handling
- [ ] Logging and monitoring
- [ ] Documentation

#### Operations
- [ ] Deployment procedures
- [ ] Monitoring setup
- [ ] Backup procedures
- [ ] Incident response
- [ ] Maintenance schedule

### Production Configuration

#### 1. Environment Configuration
```bash
# Production environment variables
export R_ENVIRON="/etc/R/Renviron.site"
export R_LIBS_USER="/opt/R/packages"
export R_MAX_MEMORY="32GB"
export PIPELINE_LOG_LEVEL="INFO"
export PIPELINE_LOG_FILE="/var/log/lab-analysis.log"
```

#### 2. System Configuration
```bash
# Increase file limits
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Increase memory limits
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
```

#### 3. R Configuration
```r
# /etc/R/Renviron.site
R_LIBS_USER="/opt/R/packages"
R_MAX_MEMORY="32GB"
R_DEFAULT_PACKAGES="data.table,argparse"
```

### Monitoring and Alerting

#### 1. Application Monitoring
```bash
# Monitor pipeline execution
tail -f /var/log/lab-analysis.log

# Monitor system resources
htop
iostat -x 1
free -h
```

#### 2. Log Monitoring
```bash
# Set up log rotation
cat > /etc/logrotate.d/lab-analysis << EOF
/var/log/lab-analysis.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF
```

#### 3. Alerting
```bash
# Set up email alerts
echo "Pipeline completed successfully" | mail -s "Lab Analysis Complete" admin@example.com

# Set up monitoring script
cat > /opt/scripts/monitor_pipeline.sh << 'EOF'
#!/bin/bash
if ! pgrep -f "run_analysis.sh" > /dev/null; then
    echo "Pipeline not running" | mail -s "Pipeline Alert" admin@example.com
fi
EOF

# Add to crontab
echo "*/5 * * * * /opt/scripts/monitor_pipeline.sh" | crontab -
```

## Monitoring and Maintenance

### System Monitoring

#### 1. Resource Monitoring
```bash
# Monitor CPU usage
top -p $(pgrep -f "Rscript")

# Monitor memory usage
free -h
ps aux | grep Rscript

# Monitor disk usage
df -h
du -sh /path/to/data
```

#### 2. Application Monitoring
```bash
# Monitor pipeline logs
tail -f /var/log/lab-analysis.log

# Check pipeline status
ps aux | grep run_analysis.sh

# Monitor output files
ls -la /path/to/output/
```

### Maintenance Procedures

#### 1. Regular Maintenance
```bash
# Clean up temporary files
find /tmp -name "Rtmp*" -mtime +7 -delete

# Clean up old output files
find /path/to/output -name "*.csv" -mtime +30 -delete

# Update R packages
Rscript -e "update.packages(ask = FALSE)"
```

#### 2. Backup Procedures
```bash
# Backup data
tar -czf data_backup_$(date +%Y%m%d).tar.gz /path/to/data

# Backup results
tar -czf results_backup_$(date +%Y%m%d).tar.gz /path/to/results

# Backup configuration
cp -r /etc/R /path/to/backup/R_config_$(date +%Y%m%d)
```

#### 3. Update Procedures
```bash
# Update pipeline code
cd /path/to/pipeline
git pull origin main

# Update dependencies
Rscript setup.R

# Test update
./run_analysis.sh full --input_dir example_data --n_patients 5
```

### Troubleshooting

#### 1. Common Issues
- **Memory issues:** Increase system memory or reduce dataset size
- **Disk space:** Clean up old files or increase storage
- **Performance:** Optimize parameters or upgrade hardware
- **Network issues:** Check connectivity and firewall settings

#### 2. Recovery Procedures
- **Data corruption:** Restore from backup
- **System failure:** Restart services or reboot
- **Pipeline failure:** Check logs and restart
- **Resource exhaustion:** Scale up or optimize

#### 3. Emergency Procedures
- **Stop pipeline:** `pkill -f "run_analysis.sh"`
- **Restart services:** `systemctl restart lab-analysis`
- **Emergency backup:** `tar -czf emergency_backup.tar.gz /path/to/data`
- **Contact support:** Follow escalation procedures

## Security Considerations

### Data Security
- Encrypt data at rest and in transit
- Use secure authentication
- Implement access controls
- Regular security audits

### System Security
- Keep systems updated
- Use firewalls and VPNs
- Monitor for intrusions
- Implement backup procedures

### Compliance
- Follow data privacy regulations
- Implement audit trails
- Regular compliance checks
- Document security procedures

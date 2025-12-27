#!/bin/bash

# AWS Deployment Helper Script
# Usage: ./deploy_aws.sh

echo "Starting deployment setup..."

# 1. Update System & Install Dependencies
echo "Updating system packages..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv git

# 2. Setup Project Directory
REPO_URL="https://github.com/iyadangky/django-project-aws-sise.git"
PROJECT_DIR="django-project-aws-sise"

if [ -d "$PROJECT_DIR" ]; then
    echo "Project exists. Pulling latest changes..."
    cd $PROJECT_DIR
    git pull
else
    echo "Cloning repository..."
    git clone $REPO_URL
    cd $PROJECT_DIR
fi

# 3. Virtual Environment Setup
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

# 4. Install Dependencies
echo "Installing requirements..."
pip install -r requirements.txt

# 5. Django Setup
echo "Running migrations..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

# 6. Service Configuration (Nginx & Gunicorn)
echo "Configuring Nginx & Gunicorn..."

# Install Nginx if not present
if ! command -v nginx &> /dev/null; then
    sudo apt-get install -y nginx
fi

# Copy Gunicorn service
sudo cp gunicorn.service /etc/systemd/system/gunicorn.service
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Configure Nginx
sudo cp nginx_app.conf /etc/nginx/sites-available/appraisal_project
# Enable the site (remove default if exists)
sudo ln -sf /etc/nginx/sites-available/appraisal_project /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Check configuration and restart
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart gunicorn

echo "Deployment setup complete!"
echo "Your site should be live at http://3.36.121.211"


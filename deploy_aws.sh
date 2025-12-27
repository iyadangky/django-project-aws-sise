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

echo "Deployment setup complete!"
echo "To run the server for testing: python manage.py runserver 0.0.0.0:8000"
echo "Note: Ensure AWS Security Group allows inbound traffic on port 8000."

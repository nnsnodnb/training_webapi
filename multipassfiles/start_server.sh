#!/bin/bash -e

cd /home/ubuntu/training_webapi

# Install dependencies
/home/ubuntu/.pyenv/shims/pip install pipenv
/home/ubuntu/.pyenv/shims/pipenv install --dev

# Configure AWS profile
mkdir -p /home/ubuntu/.aws

if [[ ! -e /home/ubuntu/.aws/config ]]; then
cat > /home/ubuntu/.aws/config << EOF
[profile default]
region = ap-northeast-1
output = json
s3 =
  endpoint_url = http://127.0.0.1:9000
EOF
fi

if [[ ! -e /home/ubuntu/.aws/credentials ]]; then
cat > /home/ubuntu/.aws/credentials << EOF
[default]
aws_access_key_id = access_key
aws_secret_access_key = secret_key
EOF
fi

# Update S3 Bucket Policy
/home/ubuntu/.pyenv/shims/pipenv run aws s3api put-bucket-policy \
  --bucket training-store \
  --policy file://dockerfiles/files/s3_policy.json \
  --endpoint-url http://127.0.0.1:9000

# Migration
/home/ubuntu/.pyenv/shims/pipenv run python manage.py migrate

# Collectstatic
/home/ubuntu/.pyenv/shims/pipenv run python manage.py collectstatic --no-input

# Run server
sudo systemctl start gunicorn.service
sudo systemctl enable gunicorn.service

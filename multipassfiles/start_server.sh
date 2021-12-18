#!/bin/bash -e

cd /home/ubuntu/training_webapi

# Install dependencies
pip install pipenv
pipenv install --dev

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
pipenv run aws s3api put-bucket-policy \
        --bucket training-store \
        --policy file://dockerfiles/files/s3_policy.json \
        --endpoint-url http://127.0.0.1:9000

# Migration
pipenv run python manage.py migrate

# Collectstatic
pipenv run python manage.py collectstatic --no-input

# Run server
pipenv run gunicorn training.wsgi:application -k gevent -w 3 -b unix:/tmp/gunicorn.sock -D

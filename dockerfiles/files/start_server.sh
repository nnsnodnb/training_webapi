#!/bin/bash -e

# dockerize
dockerize -wait tcp://proxy:80 -wait tcp://db:5432 -wait tcp://storage:9000 -timeout 30s

# Install dependencies
pip install -U pip
pip install pipenv
pipenv install --dev

# Configure AWS profile
mkdir -p /root/.aws

if [[ ! -e /root/.aws/config ]]; then
cat > /root/.aws/config << EOF
[profile default]
region = ap-northeast-1
output = json
s3 =
  endpoint_url = http://storage:9000
EOF
fi

if [[ ! -e /root/.aws/credentials ]]; then
cat > /root/.aws/credentials << EOF
[default]
aws_access_key_id = access_key
aws_secret_access_key = secret_key
EOF
fi

# Create S3 Bucket
if pipenv run aws s3 ls s3://training-store --endpoint-url http://storage:9000 2>&1 | grep -q 'NoSuchBucket'; then
    pipenv run aws s3api create-bucket \
        --bucket training-store \
        --endpoint-url http://storage:9000
    pipenv run aws s3api put-bucket-policy \
        --bucket training-store \
        --policy file://dockerfiles/files/s3_policy.json \
        --endpoint-url http://storage:9000
fi

# Migration
pipenv run python manage.py migrate

# Collectstatic
pipenv run python manage.py collectstatic --no-input

# Run server
mkdir -p tmp
pipenv run gunicorn training.wsgi:application -k eventlet -c gunicorn_conf.py

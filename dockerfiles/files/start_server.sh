#!/bin/bash -e

# Install dependencies
pip install -U pip
pip install poetry
poetry install --no-root

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
if poetry run aws s3 ls s3://training-store --endpoint-url http://storage:9000 2>&1 | grep -q 'NoSuchBucket'; then
    poetry run aws s3api create-bucket \
        --bucket training-store \
        --endpoint-url http://storage:9000
    poetry run aws s3api put-bucket-policy \
        --bucket training-store \
        --policy file://dockerfiles/files/s3_policy.json \
        --endpoint-url http://storage:9000
fi

# Migration
poetry run python manage.py migrate

# Create superuser when out exists user
poetry run python manage.py shell -c 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username="admin").exists() or User.objects.create_superuser(username="admin", email="admin@example.com", password="adminpassword")'

# Collectstatic
poetry run python manage.py collectstatic --no-input

# Run server
mkdir -p tmp
poetry run gunicorn training.wsgi:application -k gevent -c gunicorn_conf.py

#!/bin/bash -e

# dockerize
dockerize -wait tcp://db:5432 -wait tcp://storage:9000 -timeout 30s

# Install dependencies
python -m pip install -U pip
python -m pip install pipenv
python -m pipenv install --dev

# Configure AWS profile
python -m pipenv run aws configure set aws_access_key_id access_key --profile default
python -m pipenv run aws configure set aws_secret_access_key secret_key --profile default
python -m pipenv run aws configure set default.region ap-northeast-1

# Create S3 Bucket
if python -m pipenv run aws s3 ls s3://training-store 2>&1 | grep -q 'NoSuchBucket'; then
    python -m pipenv run aws s3api create-bucket \
        --bucket training-store \
        --endpoint-url http://storage:9000
    python -m pipenv run aws s3api put-bucket-policy \
        --bucket training-store \
        --policy file://dockerfiles/files/s3_policy.json \
        --endpoint-url http://storage:9000
fi

# Migration
python -m pipenv run python manage.py migrate

# Run server
python -m pipenv run gunicorn training.wsgi:application -k gevent -c gunicorn_conf.py

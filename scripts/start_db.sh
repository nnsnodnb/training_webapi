#!/usr/bin/env bash -eu

docker run \
  -d \
  --restart always \
  -p 5432:5432 \
  -v db_data:/var/lib/postgresql/data \
  -e POSTGRES_INITDB_ARGS="--encoding=UTF=8 --locale=C" \
  -e POSTGRES_USER="training" \
  -e POSTGRES_PASSWORD="training_very_secret_password" \
  -e POSTGRES_NAME="training" \
  -e PGDATA="/var/lib/postgresql/data" \
  -e TZ="Asia/Tokyo" \
  postgres:14.1

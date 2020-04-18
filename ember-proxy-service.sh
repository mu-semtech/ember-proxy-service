#!/bin/bash

REGEX=$(echo "$STATIC_FOLDERS_REGEX" | sed -e 's/[\/&]/\\&/g')

sed -i "s/STATIC_FOLDERS_REGEX/$REGEX/" /etc/nginx/conf.d/app.conf

# Replace environment variables in the build of the frontend
PREFIX="CONFIG_"
ENV_VARIABLES=$(env | grep "${PREFIX}")

while IFS= read -r line; do
  ENV_VARIABLE=$(echo "$line" | sed -e "s/^$PREFIX//" | cut -f1 -d"=")
  VALUE=$(echo "$line" | cut -d"=" -f2-)
  sed -i "s/%7B%7B$ENV_VARIABLE%7D%7D/$VALUE/g" /app/index.html
done <<< "$ENV_VARIABLES"

nginx -g "daemon off;"

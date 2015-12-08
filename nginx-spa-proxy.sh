#!/bin/bash

REGEX=$(echo "$STATIC_FOLDERS_REGEX" | sed -e 's/[\/&]/\\&/g')

sed -i "s/STATIC_FOLDERS_REGEX/$REGEX/" /etc/nginx/conf.d/app.conf

nginx -g "daemon off;"

# Ember proxy service
Nginx hosting an Ember app with a backend API #ember-cli #Ember.js

## Running your Ember app
    docker run --name my-app \
        --link my-backend-container:backend \
        -v /path/to/spa/dist:/app:ro \
        -d semtech/ember-proxy-service

All HTML requests and requests to a location matching `$STATIC_FOLDERS_REGEX` (default: `^/(assets|font)/`) are served by the Ember app. Remaining requests are proxied to the backend API.

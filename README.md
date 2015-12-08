# Nginx Single Page App proxy docker
Nginx hosting a Single Page App with a backend API #ember-cli #Ember.js #AngularJS

## Running your Single Page App
    docker run --name my-app \
        --link my-backend-container:backend \
        -v /path/to/spa/dist:/app:ro \
        -d semtech/mu-nginx-spa-proxy

All HTML requests and requests to a location matching `$STATIC_FOLDERS_REGEX` (default: `^/(assets|font)/`) are served by the Single Page App. Remaining requests are proxied to the backend API.

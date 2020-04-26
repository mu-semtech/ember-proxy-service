# Ember proxy service
Nginx hosting an Ember app with a backend API #ember-cli #Ember.js

## Running your Ember app
    docker run --name my-app \
        --link my-backend-container:backend \
        -v /path/to/spa/dist:/app \
        -v /path/to/config:/config \
        -d semtech/ember-proxy-service

All HTML requests and requests to a location matching the regex in the `STATIC_FOLDERS_REGEX` environment variable (default: `^/(assets|font)/`) are served by the Ember app. Remaining requests are proxied to the backend API.

Custom Nginx configurations with a name like `*.conf` can be mounted in `/config` and will be included automatically.

## Using environment variables at run time with an Ember application

The service can use environment variables to configure a frontend build at runtime. It will get the environment variables prefixed by `EMBER_` and match them with the variables defined in the frontend's configuration. It will then update the file `/app/index.html` the use the values of the environment variables that matched.

### Configure environment variables in the frontend's container

The environment variables have to be prefixed by `EMBER_` to be recognized by the service as variables to be matched. By using docker-compose, the service configuration will look like:

    docker-compose.yml

    frontend:
        environment:
            EMBER_VAR_EXAMPLE: "example-value"

### Configure the frontend's variables

The frontend's configuration will use `{{VAR_EXAMPLE}}` as a placeholder that will be replaced by this service at runtime.

    config/environment.js

    if (environment === 'production') {
        ENV['VAR_EXAMPLE'] = '{{VAR_EXAMPLE}}'
    }

# Ember proxy service
Nginx hosting an Ember app with a backend API #ember-cli #Ember.js

## Tutorial: Hosting an EmberJS app with a backend API
![](http://mu.semte.ch/wp-content/uploads/2017/05/mu_semte_ch_of_oz-1024x683.png)

In the mu.semte.ch framework we use EmberJS in the frontend. The data is retrieved through [Ember Data](https://emberjs.com/api/data/) or AJAX requests, via the identifier and dispatcher, from the microservices in the backend. Aad Versteden has already explained in a previous blog post [how to use  an Ember docker to facilitate the development with ember-cli](https://mu.semte.ch/2017/03/09/developing-emberjs-with-docker/) and connect to the backend microservices through a proxy. In this article we will focus on the hosting of an Ember application in a production environment using the Ember proxy service docker image.

### Hosting the app on an HTTP server

The frontend application is basically a collection of static javascript, HTML, CSS, … files that need to be hosted on an HTTP server like Nginx or Apache. Besides just hosting the static files, the HTTP server also needs to proxy specific requests to the backend API. How does the HTTP server know which requests should be served by the Ember app and which requests should be proxied to the backend?

What’s typically done, is hosting the backend API on the /api path. As a result the HTTP server can decide with a simple regex on the request URL whether the request must be served by the Ember app or by the backend API. This approach however puts a limit on your backend API since all the API paths must start with /api.

To circumvent this limitation on the backend we’ve created [a Nginx proxy service](https://github.com/mu-semtech/ember-proxy-service) that just does what you need. Just add your frontend app and it will automatically make the Ember app serve all HTML requests and requests to a path matching the regex ^/(assets|font)/. All remaining requests will be proxied to the backend. Have a look at [the Nginx configuration](nginx.conf) in the container if you want to know how this works in depth (it makes use of the 418 I’m a teapot HTTP status code 🙂 ).

### How to use the Nginx proxy service

Before we can create our proxy service, we first need to build the Ember application. Using [edi](github.com/madnificent/docker-ember) you can do this with the following command:
```bash
$ edi ember build -prod
```

The built application will by default be available in the `dist/` folder of your frontend application.

We now need the files in the `dist/` folder to be hosted by the proxy service. Therefore, we will extend the Nginx proxy service image with our built application. Just create a Dockerfile in your frontend application’s folder with the following contents:
```Dockerfile
FROM semtech/mu-nginx-spa-proxy:1.1.0
COPY dist/ app/
```

Next, assuming `dist/` contains the latest production build of your application, build the Docker image (or configure an automated build on Docker Hub):
```bash
$ docker build -t my-ember-app .
```

Finally, add the resulting image to your mu.semte.ch `docker-compose.yml` and link the identifier microservice as backend to the proxy service:
```yaml
version: '2'
services:
  ...
  frontend:
    image: my-ember-app
    links:
      - identifier:backend
```

### Custom configuration
The Nginx proxy service has a couple of configuration options. The regex of requests paths that must be served by the Ember app is set to `^/(assets|font)/` by default, but can be configured through the `STATIC_FOLDERS_REGEX` environment variable.

For example, with the following configuration the Ember app will also serve paths starting with `/images`.

```Dockerfile
# Dockerfile
FROM semtech/mu-nginx-spa-proxy:1.1.0
COPY dist/ app/
ENV STATIC\_FOLDERS\_REGEX "^/(assets|font|images)/"
```

You can also add some custom Nginx configuration by adding one or more `*.conf` files in the `/config` folder. They will be automatically picked up by Nginx.

For example, if you want to increase the `client_max_body_size`, create a `file_upload.conf` file with the following contents:

`client_max_body_size 50M;`

Add the `file_upload.conf` file to the `/config` in your Docker image:
```Dockerfile
FROM semtech/mu-nginx-spa-proxy:1.1.0
COPY dist/ app/
COPY file\_upload.conf /config
```

### Conclusion
The Nginx proxy service offers a simple and configurable solution to host an EmberJS application on an HTTP service with a proxy to the backend API without putting limitations on the backend request paths. In fact, the proxy service can also be used with other single page app technologies than EmberJS like for example Angular or React.

*This tutorial has been adapted from Erika Pauwels' mu.semte.ch article. You can view it [here](https://mu.semte.ch/2017/06/08/hosting-your-ember-app-with-a-backend-api/)*


## How-To
### Running your Ember app
    docker run --name my-app \
        --link my-backend-container:backend \
        -v /path/to/spa/dist:/app \
        -v /path/to/config:/config \
        -d semtech/ember-proxy-service

All HTML requests and requests to a location matching the regex in the `STATIC_FOLDERS_REGEX` environment variable (default: `^/(assets|font)/`) are served by the Ember app. Remaining requests are proxied to the backend API.

Custom Nginx configurations with a name like `*.conf` can be mounted in `/config` and will be included automatically.

### Using environment variables at run time with an Ember application

The service can use environment variables to configure a frontend build at runtime. It will get the environment variables prefixed by `EMBER_` and match them with the variables defined in the frontend's configuration. It will then update the file `/app/index.html` the use the values of the environment variables that matched.

#### Configure environment variables in the frontend's container

The environment variables have to be prefixed by `EMBER_` to be recognized by the service as variables to be matched. By using docker-compose, the service configuration will look like:

```yaml
# docker-compose.yml
frontend:
    environment:
        EMBER_VAR_EXAMPLE: "example-value"
```

#### Configure the frontend's variables

The frontend's configuration will use `{{VAR_EXAMPLE}}` as a placeholder that will be replaced by this service at runtime.
```js
// config/environment.js
if (environment === 'production') {
    ENV['VAR_EXAMPLE'] = '{{VAR_EXAMPLE}}'
}
```

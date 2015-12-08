FROM nginx:1

MAINTAINER Erika Pauwels <erika.pauwels@gmail.com>

ENV STATIC_FOLDERS_REGEX "^/(assets|font)/"

RUN rm /etc/nginx/conf.d/default.conf
ADD nginx.conf /etc/nginx/conf.d/app.conf
ADD nginx-spa-proxy.sh /

CMD ["/bin/bash", "/nginx-spa-proxy.sh"]
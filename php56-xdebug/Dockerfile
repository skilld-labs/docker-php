FROM skilldlabs/php:56
MAINTAINER Andy Postnikov <andypost@ya.ru>

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php-xdebug \
  && ln -s /usr/lib/php/modules/xdebug.so /usr/lib/php5/modules/xdebug.so \
  && ln -s /etc/php/conf.d/xdebug.ini /etc/php5/conf.d/xdebug.ini \
  && rm -fr /var/cache/apk/*

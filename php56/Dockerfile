FROM alpine:3.4
MAINTAINER Andy Postnikov <andypost@ya.ru>

# persistent / runtime deps
ENV PHPIZE_DEPS \
  autoconf \
  file \
  g++ \
  gcc \
  libc-dev \
  make \
  pkgconf \
  re2c

# add php7-xdebug if needed
ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  openssl \
  patch

RUN apk add --no-cache \
  php5 \
  php5-apcu \
  php5-bcmath \
  php5-ctype \
  php5-curl \
  php5-dom \
  php5-gd \
  php5-json \
  php5-mcrypt \
  php5-opcache \
  php5-openssl \
  php5-pcntl \
  php5-pdo_mysql \
  php5-pdo_sqlite \
  php5-phar \
  php5-xml \
  php5-zlib \
  $PHPRUN_DEPS \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php-xdebug \
  && rm -fr /var/cache/apk/* \
  && wget https://getcomposer.org/installer -O - | php -- --filename=composer \
  --install-dir=/usr/bin \
  && wget http://files.drush.org/drush.phar -O /usr/bin/drush && chmod +x /usr/bin/drush

COPY php.ini /etc/php5/conf.d/xx-drupal.ini

WORKDIR /srv

EXPOSE 80

CMD php -t /srv -S 0.0.0.0:80

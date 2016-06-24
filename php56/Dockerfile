FROM alpine:edge
MAINTAINER Andy Postnikov <andypost@ya.ru>

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
  && rm -fr /var/cache/apk/* \
  && wget https://getcomposer.org/installer -O - | php -- --filename=composer \
  --install-dir=/usr/bin \
  && wget http://files.drush.org/drush.phar -O /usr/bin/drush && chmod +x /usr/bin/drush

COPY php.ini /etc/php5/conf.d/xx-drupal.ini

WORKDIR /srv

EXPOSE 80

CMD php -t /srv -S 0.0.0.0:80

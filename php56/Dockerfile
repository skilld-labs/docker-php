FROM alpine:edge
MAINTAINER Andy Postnikov <andypost@ya.ru>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Custom PHP 5.6 image" \
    org.label-schema.description="Custom PHP 5.6 image to run Drupal" \
    org.label-schema.url="https://github.com/skilld-labs/docker-php" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
    org.label-schema.vendor="Skilld" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  openssl \
  patch

ENV TERM xterm

RUN apk add --no-cache --upgrade \
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

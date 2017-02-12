FROM alpine:3.5

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  openssl \
  patch \
  sqlite

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --no-cache \
  php5 \
  php5-fpm \
  php5-apcu \
  php5-bcmath \
  php5-ctype \
  php5-curl \
  php5-dom \
  php5-gd \
  php5-gmp \
  php5-json \
  php5-mcrypt \
  php5-opcache \
  php5-openssl \
  php5-pcntl \
  php5-pdo_mysql \
  php5-pdo_sqlite \
  php5-phar \
  php5-xdebug \
  php5-xml \
  php5-zlib \
  $PHPRUN_DEPS \
  && rm -fr /var/cache/apk/* \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php-fpm.conf /etc/php5/
COPY php.ini /etc/php5/conf.d/xx-drupal.ini

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm", "-F"]

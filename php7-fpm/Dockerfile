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

# Add optional packages.
ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  patch \
  sqlite

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --no-cache \
  php7 \
  php7-fpm \
  php7-apcu \
  php7-bcmath \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-gd \
  php7-gmp \
  php7-json \
  php7-mbstring \
  php7-mcrypt \
  php7-opcache \
  php7-openssl \
  php7-pcntl \
  php7-pdo_mysql \
  php7-pdo_sqlite \
  php7-phar \
  php7-session \
  php7-xdebug \
  php7-xml \
  php7-zlib \
  $PHPRUN_DEPS \
  && rm -fr /var/cache/apk/* \
  && ln -s /usr/bin/php7 /usr/bin/php \
  && php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php7 composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php7 -r "unlink('composer-setup.php');" \
  && php7 -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php-fpm.conf /etc/php7/
COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm7", "-F"]

FROM php:7.1-fpm-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Taras Kyryliuk <tkiriluk@gmail.com>"

ENV PHP_INI_DIR /usr/local/etc/php

# Packages to install php ext
ENV PHP_BUILD_DEPS \
  libmcrypt-dev \
  postgresql-dev \
  freetype \
  libpng \
  libjpeg-turbo \
  freetype-dev \
  libpng-dev \
  libjpeg-turbo-dev

RUN set -ex \
  # Install additional packages
  && apk add --no-cache \
    mariadb-client \
    patch \
    $PHP_BUILD_DEPS \
    $PHPIZE_DEPS \

  # Install XDebug
  && yes | pecl install xdebug \

  # Install php ext
  && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" \
    gd \
    bcmath \
    mcrypt \
    pcntl \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    zip \
  && apk del --purge freetype-dev libpng-dev libjpeg-turbo-dev \

  # Add php.ini
  && docker-php-source extract \
  && cp /usr/src/php/php.ini-development "$PHP_INI_DIR/php.ini" \
  && docker-php-source delete \

  # Install composer.
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \

  # Install Drush.
  && php -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush \

  # Cleanup
  && apk del --purge --no-cache \
      build-base \
      autoconf \
      libtool \
      $PHPIZE_DEPS \
  && rm -rf \
      /usr/local/include/php \
      /usr/local/lib/php/build \
      /var/cache/apk/*v \
      /tmp/* \
      /root/.composer \
      /usr/src/php

COPY php-fpm.conf /usr/local/etc/
COPY php.ini $PHP_INI_DIR/conf.d/xx-drupal.ini

COPY skilld-php-entrypoint.sh /usr/local/bin/skilld-php-entrypoint
ENTRYPOINT ["skilld-php-entrypoint"]

WORKDIR /var/www/html

CMD ["php-fpm"]

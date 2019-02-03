FROM alpine:3.5

ARG COMPOSER_HASH
ARG DRUSH_VERSION
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
  git \
  mariadb-client \
  openssh-client \
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
  php5-iconv \
  php5-json \
  php5-opcache \
  php5-openssl \
  php5-pcntl \
  php5-pdo_mysql \
  php5-pdo_sqlite \
  php5-phar \
  php5-xml \
  php5-xmlreader \
  php5-zlib \
  $PHPRUN_DEPS \
# build extra extensions
  && apk add --update --virtual .php-build \
  php5-dev php5-pear make gcc g++ autoconf pcre-dev \
  && sed -ie 's/-n//g' /usr/bin/pecl \
  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install xdebug-2.5.5 \
# clean-up
  && apk del .php-build \
  && rm -fr /tmp/pear /usr/include /usr/share/pear /var/cache/apk/* \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush && /usr/bin/drush version

COPY php-fpm.conf /etc/php5/
COPY php.ini /etc/php5/conf.d/xx-drupal.ini

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm5", "-F"]

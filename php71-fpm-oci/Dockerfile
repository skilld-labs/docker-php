FROM frolvlad/alpine-glibc:alpine-3.5_glibc-2.24

ENV LD_LIBRARY_PATH=/opt/instantclient_12_2 TNS_ADMIN=/opt ORACLE_HOME=/opt/instantclient_12_2

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer, drush, oci8" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV COMPOSER_HASH=669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410
ENV PHPRUN_DEPS \
  curl \
  libaio \
  mariadb-client \
  patch \
  sqlite

COPY dist/instantclient* /tmp/

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --upgrade --no-cache \
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
  php7-pdo \
  php7-pdo_mysql \
  php7-pdo_sqlite \
  php7-phar \
  php7-session \
  php7-xdebug \
  php7-xml \
  php7-xmlreader \
  php7-zlib \
  $PHPRUN_DEPS \

# build xdebug & apcu & oci8
  && apk add --upgrade --no-cache \
#  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  --virtual .php-build php7-dev php7-pear pcre-dev autoconf build-base unzip \
  && sed -ie 's/-n//g' /usr/bin/pecl \
# unpack client libraries
  && unzip -d /opt /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip \
  && unzip -d /opt /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip \
  && unzip -d /opt /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip \
  && rm /tmp/* -fr \
  && ln -s /opt/instantclient_12_2/sqlplus /usr/local/bin/ \

  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install oci8 \
  && echo 'extension=oci8.so' > /etc/php7/conf.d/oci8.ini \
# clean-up
  && apk del --no-cache .php-build \
  && rm -rf /usr/include /usr/share/pear /tmp/pear \

#  && ln -s /usr/sbin/php-fpm7.1 /usr/sbin/php-fpm7 \
  && rm -fr /var/cache/apk/* \
  && ln -s /usr/bin/php7 /usr/bin/php \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php-fpm.conf /etc/php7/
COPY php.ini /etc/php7/conf.d/xx-drupal.ini

#USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

CMD ["php-fpm7", "-F"]

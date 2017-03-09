FROM alpine:edge

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV COMPOSER_HASH=669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410
ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  patch \
  sqlite

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --upgrade --no-cache \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php7.1 \
  php7.1-fpm \
#  php7-apcu \
  php7.1-bcmath \
  php7.1-ctype \
  php7.1-curl \
  php7.1-dom \
  php7.1-gd \
  php7.1-gmp \
  php7.1-json \
  php7.1-mbstring \
  php7.1-mcrypt \
  php7.1-opcache \
  php7.1-openssl \
  php7.1-pcntl \
  php7.1-pdo_mysql \
  php7.1-pdo_sqlite \
  php7.1-phar \
  php7.1-session \
#  php7-xdebug \
  php7.1-xml \
  php7.1-xmlwriter \
  php7.1-zlib \
  $PHPRUN_DEPS \

# build xdebug & apcu
  && apk add --upgrade --no-cache \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  --virtual .php-build php7.1-dev php7.1-pear pcre-dev autoconf build-base \
#  && sed -ie 's/-n//g' /usr/bin/pecl \
  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install apcu xdebug \
  && echo 'extension=apcu.so' > /etc/php7.1/conf.d/apcu.ini \
# clean-up
  && apk del --no-cache .php-build \
  && rm -rf /usr/include /usr/share/pear /tmp/pear \

  && ln -s /usr/sbin/php-fpm7.1 /usr/sbin/php-fpm7 \
  && rm -fr /var/cache/apk/* \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php-fpm.conf /etc/php7.1/
COPY php.ini /etc/php7.1/conf.d/xx-drupal.ini

#USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

CMD ["php-fpm7.1", "-F"]

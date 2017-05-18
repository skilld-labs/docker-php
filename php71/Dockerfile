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
  && apk add --upgrade --no-cache \
  --repository http://nl.alpinelinux.org/alpine/edge/community \
  php7 \
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
  php7-simplexml \
  php7-tokenizer \
  php7-xdebug \
  php7-xml \
  php7-xmlwriter \
  php7-zlib \
  $PHPRUN_DEPS \

# build xdebug & apcu
#  && apk add --upgrade --no-cache \
#  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
#  --virtual .php-build php7-dev php7-pear pcre-dev autoconf build-base \
#  && sed -ie 's/-n//g' /usr/bin/pecl \
#  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install apcu xdebug \
#  && echo 'extension=apcu.so' > /etc/php7/conf.d/apcu.ini \
# clean-up
#  && apk del --no-cache .php-build \
#  && rm -rf /usr/include /usr/share/pear /tmp/pear \

  && rm -fr /var/cache/apk/* \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

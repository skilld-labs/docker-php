# syntax = docker/dockerfile:1.0-experimental
FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 8 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV PHPRUN_DEPS \
  curl \
  git \
  make \
  mariadb-client \
  openssh-client \
  patch \
  sqlite

RUN --mount=type=bind,source=keys,target=/var/cache/keys \
  --mount=type=bind,source=packages/testing,target=/var/cache/php8 \
  set -e \
  && cp /var/cache/keys/alpine-infra@*.pub /etc/apk/keys/ \
  && apk add --upgrade -X /var/cache/php8 \
  php8 \
#  php8-pecl-apcu \
#  php8-pecl-igbinary \
#  php8-pecl-xdebug \
  php8-bcmath \
  php8-ctype \
  php8-curl \
  php8-dom \
  php8-fileinfo \
  php8-gd \
  php8-gmp \
  php8-iconv \
#  php8-json \
  php8-mbstring \
  php8-opcache \
  php8-openssl \
  php8-pcntl \
  php8-pdo_mysql \
  php8-pdo_sqlite \
  php8-phar \
  php8-session \
  php8-simplexml \
  php8-tokenizer \
  php8-xml \
  php8-xmlreader \
  php8-xmlwriter \
  $PHPRUN_DEPS \
  && ln -s /usr/bin/php8 /usr/bin/php \
# build extra extensions
  && apk add -X /var/cache/php8 --virtual .php-build \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php8-dev php8-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl8 \
  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  pecl8 install apcu igbinary \
  && echo 'extension=apcu' > /etc/php8/conf.d/apcu.ini \
  && echo 'extension=igbinary' > /etc/php8/conf.d/10_igbinary.ini \
  && strip /usr/lib/php8/modules/apcu.so /usr/lib/php8/modules/igbinary.so \
  && wget https://github.com/xdebug/xdebug/archive/master.zip && unzip master.zip && rm master.zip \
  && cd xdebug-master && phpize8 && ./configure --with-php-config=php-config8 \
  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  make install \
  && cd .. && rm -rf xdebug-master \
  && echo ';zend_extension=xdebug' > /etc/php8/conf.d/xdebug.ini \
  && strip /usr/lib/php8/modules/xdebug.so \
# clean-up
  && apk del .php-build \
  && rm -fr /tmp/pear /usr/include /usr/share/pear /usr/share/php8 /var/cache/apk/* \
  /root/.drush/cache /etc/apk/keys/alpine-infra@*.pub \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush && /usr/bin/drush version

COPY php.ini /etc/php8/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

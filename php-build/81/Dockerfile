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
  org.label-schema.description="PHP 8.1 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
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
  --mount=type=bind,source=packages/testing,target=/var/cache/php81 \
  set -e \
  && cp /var/cache/keys/skilld-*.pub /etc/apk/keys/ \
  && apk add --upgrade -X /var/cache/php81 \
  php81 \
#  php81-pecl-apcu \
#  php81-pecl-igbinary \
#  php81-pecl-xdebug \
  php81-bcmath \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fileinfo \
  php81-gd \
  php81-gmp \
  php81-iconv \
#  php81-json \
  php81-mbstring \
  php81-opcache \
  php81-openssl \
  php81-pcntl \
  php81-pdo_mysql \
  php81-pdo_sqlite \
  php81-phar \
  php81-session \
  php81-simplexml \
  php81-tokenizer \
  php81-xml \
  php81-xmlreader \
  php81-xmlwriter \
  $PHPRUN_DEPS \
  && ln -s php81 /usr/bin/php \
# build extra extensions
  && apk add -X /var/cache/php81 --virtual .php-build \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php81-dev php81-pear g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl8 \
  && pecl81 bundle apcu && cd apcu && curl https://github.com/krakjoe/apcu/commit/ddc5a8b86f88495aa2da1e9df2f6d187c420c3c1.patch |patch -p1 && cd - \
  && cd apcu && phpize81 && ./configure --with-php-config=php-config81 \
  && CFLAGS="-O2 -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  make install \
  && echo 'extension=apcu' > /etc/php81/conf.d/apcu.ini \
  && strip /usr/lib/php81/modules/apcu.so \
  && cd .. && rm -rf apcu* channel.xml \
  && CFLAGS="-O2 -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  pecl81 install igbinary redis \
  && echo 'extension=igbinary' > /etc/php81/conf.d/10_igbinary.ini \
  && cd /usr/lib/php81/modules && strip igbinary.so redis.so && cd - \
  && CFLAGS="-O2 -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  pecl81 install -n xdebug \
  && echo ';zend_extension=xdebug' > /etc/php81/conf.d/xdebug.ini \
  && strip /usr/lib/php81/modules/xdebug.so \
# clean-up
  && apk del .php-build \
  && rm -fr /tmp/pear /usr/include /usr/share/pear /usr/share/php81 /var/cache/apk/* \
  /root/.drush/cache /etc/apk/keys/skilld-*.pub \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush && /usr/bin/drush version

COPY php.ini /etc/php81/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

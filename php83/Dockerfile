FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 8.3 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV PHPRUN_DEPS \
  curl \
  git \
  make \
  mariadb-client \
  openssh-client \
  patch \
  rsync \
  sqlite

RUN set -e \
  && apk --update upgrade \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && apk add --upgrade \
  php83 \
  php83-brotli \
  php83-pecl-apcu \
  php83-pecl-igbinary \
  php83-pecl-uploadprogress \
  php83-pecl-xdebug \
  php83-bcmath \
  php83-ctype \
  php83-curl \
  php83-dom \
  php83-fileinfo \
  php83-gd \
  php83-gmp \
  php83-iconv \
  php83-mbstring \
  php83-opcache \
  php83-openssl \
  php83-pcntl \
  php83-pdo_mysql \
  php83-pdo_sqlite \
  php83-phar \
  php83-session \
  php83-simplexml \
  php83-sqlite3 \
  php83-tokenizer \
  php83-xml \
  php83-xmlreader \
  php83-xmlwriter \
  php83-zip \
  $PHPRUN_DEPS \
  && ln -fs php83 /usr/bin/php \
# build extra extensions
#  && apk add --virtual .php-build \
#  php83-dev php83-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl83 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl83 install redis \
#  && echo 'extension=redis' > /etc/php83/conf.d/redis.ini \
#  && echo 'xhprof.output_dir=/tmp' >> /etc/php83/conf.d/xhprof.ini \
#  && strip /usr/lib/php83/modules/redis.so \
#  && wget https://github.com/xdebug/xdebug/archive/master.zip && unzip master.zip && rm master.zip \
#  && cd xdebug-master && phpize83 && ./configure --with-php-config=php-config83 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl83 install xdebug-3.0.0 \
#  make install \
#  && cd .. && rm -rf xdebug-master \
#  && echo ';zend_extension=xdebug' > /etc/php83/conf.d/xdebug.ini \
#  && strip /usr/lib/php83/modules/xdebug.so \
# clean-up
#  && apk del --no-network .php-build \
#  && rm -fr /tmp/pear /usr/include /usr/share/pear \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer2 \
  --2 \
  && ln -s composer2 /usr/bin/composer \
  && php -r "unlink('composer-setup.php');" \
#  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
#  && chmod +x /usr/bin/drush && /usr/bin/drush version && rm -fr /root/.drush \
  && rm -fr /var/cache/apk/*

COPY --chmod=0755 drush.phar /usr/bin/drush

COPY php.ini /etc/php83/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

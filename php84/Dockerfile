FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 8.4 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
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
  php84 \
  php84-pecl-apcu \
  php84-pecl-brotli \
  php84-pecl-igbinary \
  php84-pecl-uploadprogress \
  php84-pecl-xdebug \
  php84-bcmath \
  php84-ctype \
  php84-curl \
  php84-dom \
  php84-fileinfo \
  php84-gd \
  php84-gmp \
  php84-iconv \
  php84-mbstring \
  php84-opcache \
  php84-openssl \
  php84-pcntl \
  php84-pdo_mysql \
  php84-pdo_sqlite \
  php84-phar \
  php84-session \
  php84-simplexml \
  php84-sqlite3 \
  php84-tokenizer \
  php84-xml \
  php84-xmlreader \
  php84-xmlwriter \
  php84-zip \
  $PHPRUN_DEPS \
  && ln -fs php84 /usr/bin/php \
# build extra extensions
#  && apk add --virtual .php-build \
#  php84-dev php84-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl83 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl83 install redis \
#  && echo 'extension=redis' > /etc/php84/conf.d/redis.ini \
#  && echo 'xhprof.output_dir=/tmp' >> /etc/php84/conf.d/xhprof.ini \
#  && strip /usr/lib/php84/modules/redis.so \
#  && wget https://github.com/xdebug/xdebug/archive/master.zip && unzip master.zip && rm master.zip \
#  && cd xdebug-master && phpize83 && ./configure --with-php-config=php-config83 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl83 install xdebug-3.0.0 \
#  make install \
#  && cd .. && rm -rf xdebug-master \
#  && echo ';zend_extension=xdebug' > /etc/php84/conf.d/xdebug.ini \
#  && strip /usr/lib/php84/modules/xdebug.so \
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

COPY php.ini /etc/php84/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

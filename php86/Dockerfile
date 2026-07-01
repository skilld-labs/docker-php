FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 8.6 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
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
  && apk add '!usr-merge-nag' \
  && apk --update upgrade \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && apk add --upgrade \
  php86 \
  php86-pecl-apcu \
  php86-pecl-brotli \
  php86-pecl-igbinary \
  php86-pecl-uploadprogress \
  php86-bcmath \
  php86-ctype \
  php86-curl \
  php86-dom \
  php86-fileinfo \
  php86-gd \
  php86-gmp \
  php86-iconv \
  php86-mbstring \
  php86-openssl \
  php86-pcntl \
  php86-pdo_mysql \
  php86-pdo_sqlite \
  php86-phar \
  php86-session \
  php86-simplexml \
  php86-sqlite3 \
  php86-tokenizer \
  php86-xml \
  php86-xmlreader \
  php86-xmlwriter \
  php86-zip \
  $PHPRUN_DEPS \
  && ln -fs php86 /usr/bin/php \
# build extra extensions
#  && apk add --virtual .php-build \
#  php86-dev php86-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl86 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl86 install redis \
#  && echo 'extension=redis' > /etc/php86/conf.d/redis.ini \
#  && echo 'xhprof.output_dir=/tmp' >> /etc/php86/conf.d/xhprof.ini \
#  && strip /usr/lib/php86/modules/redis.so \
#  && wget https://github.com/xdebug/xdebug/archive/master.zip && unzip master.zip && rm master.zip \
#  && cd xdebug-master && phpize86 && ./configure --with-php-config=php-config86 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl86 install xdebug-3.0.0 \
#  make install \
#  && cd .. && rm -rf xdebug-master \
#  && echo ';zend_extension=xdebug' > /etc/php86/conf.d/xdebug.ini \
#  && strip /usr/lib/php86/modules/xdebug.so \
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
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush && /usr/bin/drush version && rm -fr /root/.drush \
  && rm -fr /var/cache/apk/*

COPY php.ini /etc/php86/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

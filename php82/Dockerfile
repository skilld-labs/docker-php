FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 8.2 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
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
ENV PHP_CLI_SERVER_WORKERS 4

RUN set -e \
  && apk --update upgrade \
  && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && apk add --upgrade \
  php82 \
  php82-pecl-apcu \
  php82-pecl-igbinary \
  php82-pecl-uploadprogress \
  php82-pecl-xdebug \
  php82-bcmath \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fileinfo \
  php82-gd \
  php82-gmp \
  php82-iconv \
  php82-mbstring \
  php82-opcache \
  php82-openssl \
  php82-pcntl \
  php82-pdo_mysql \
  php82-pdo_sqlite \
  php82-phar \
  php82-session \
  php82-simplexml \
  php82-tokenizer \
  php82-xml \
  php82-xmlreader \
  php82-xmlwriter \
  php82-zip \
  $PHPRUN_DEPS \
  && ln -fs php82 /usr/bin/php \
# build extra extensions
#  && apk add --virtual .php-build \
#  php8-dev php8-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl8 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl8 install redis \
#  && echo 'extension=redis' > /etc/php8/conf.d/redis.ini \
#  && echo 'xhprof.output_dir=/tmp' >> /etc/php8/conf.d/xhprof.ini \
#  && strip /usr/lib/php8/modules/redis.so \
#  && wget https://github.com/xdebug/xdebug/archive/master.zip && unzip master.zip && rm master.zip \
#  && cd xdebug-master && phpize8 && ./configure --with-php-config=php-config8 \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl8 install xdebug-3.0.0beta1 \
#  make install \
#  && cd .. && rm -rf xdebug-master \
#  && echo ';zend_extension=xdebug' > /etc/php8/conf.d/xdebug.ini \
#  && strip /usr/lib/php8/modules/xdebug.so \
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

COPY php.ini /etc/php82/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

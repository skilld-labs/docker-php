FROM alpine:edge

ARG COMPOSER_HASH
ARG DRUSH_VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP 7.4 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
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
  && apk add --upgrade --virtual .drupal-build \
  php7 \
  php7-pecl-apcu \
  php7-pecl-igbinary \
  php7-pecl-xdebug \
  php7-bcmath \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-fileinfo \
  php7-gd \
  php7-gmp \
  php7-iconv \
  php7-json \
  php7-mbstring \
  php7-opcache \
  php7-openssl \
  php7-pcntl \
  php7-pdo_mysql \
  php7-pdo_sqlite \
  php7-phar \
  php7-session \
  php7-simplexml \
  php7-tokenizer \
  php7-xml \
  php7-xmlreader \
  php7-xmlwriter \
  php7-zip \
  $PHPRUN_DEPS \
  && ln -fs php7 /usr/bin/php \
# build extra extensions
#  && apk add --update --virtual .php-build \
#  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
#  php7-dev php7-pear make gcc g++ autoconf \
#  && sed -ie 's/-n//g' /usr/bin/pecl \
#  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing"
#  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
#  pecl install apcu igbinary xdebug \
#  && echo 'extension=apcu.so' > /etc/php7/conf.d/apcu.ini \
  && echo 'xdebug.mode=debug' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.discover_client_host=1' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.profiler_output_name=cachegrind.out.%p.%r' >> /etc/php7/conf.d/50_xdebug.ini \
# clean-up
#  && apk del --no-network .php-build \
#  && rm -fr /tmp/pear /usr/include /usr/share/pear \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer1 \
  --1 \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer2 \
  --2 \
  && ln -s composer2 /usr/bin/composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush && /usr/bin/drush version && rm -fr /root/.drush \
  && rm -fr /var/cache/apk/*

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

FROM alpine:3.5

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

ENV COMPOSER_HASH=93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8
ENV PHPRUN_DEPS \
  curl \
  git \
  mariadb-client \
  openssh-client \
  patch \
  sqlite

RUN set -e \
  && apk add --upgrade --no-cache \
  php7 \
#  php7-apcu \
  php7-bcmath \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-gd \
  php7-gmp \
  php7-iconv \
  php7-json \
  php7-mbstring \
  php7-opcache \
  php7-openssl \
  php7-pcntl \
  php7-pdo \
  php7-pdo_mysql \
  php7-pdo_sqlite \
  php7-phar \
  php7-session \
#  php7-xdebug \
  php7-xml \
  php7-xmlreader \
  php7-zlib \
  $PHPRUN_DEPS \
# build extra extensions
  && apk add --update --virtual .php-build \
  php7-dev php7-pear make gcc g++ autoconf pcre-dev \
  && sed -ie 's/-n//g' /usr/bin/pecl \
  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install apcu xdebug \
  && echo 'extension=apcu.so' > /etc/php7/conf.d/apcu.ini \
# clean-up
  && apk del .php-build \
  && rm -fr /tmp/pear /usr/include /usr/share/pear /usr/share/php7 /var/cache/apk/* \
  && ln -s /usr/bin/php7 /usr/bin/php \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/8.1.18/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

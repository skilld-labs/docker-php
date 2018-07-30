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

ENV COMPOSER_HASH=544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061
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
  php7-apcu \
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
  php7-pdo_mysql \
  php7-pdo_sqlite \
  php7-phar \
  php7-session \
  php7-simplexml \
  php7-tokenizer \
  php7-xdebug \
  php7-xml \
  php7-xmlreader \
  php7-xmlwriter \
  $PHPRUN_DEPS \
# build extra extensions
#  && apk add --update --virtual .php-build \
#  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
#  php7-dev php7-pear make gcc g++ autoconf pcre-dev \
#  && sed -ie 's/-n//g' /usr/bin/pecl \
#  && CFLAGS="-fstack-protector-strong -fpic -fpie -O2" CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" pecl install apcu xdebug \
#  && echo 'extension=apcu.so' > /etc/php7/conf.d/apcu.ini \
# clean-up
#  && apk del .php-build \
#  && rm -fr /tmp/pear /usr/include /usr/share/pear /usr/share/php7 /var/cache/apk/* \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && php -r "copy('https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

FROM alpine:edge
MAINTAINER Andy Postnikov <andypost@ya.ru>

# add php7-xdebug if needed
ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  patch \
  sqlite

RUN set -e \
  && apk add --no-cache \
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
  php7-xdebug \
  php7-xml \
  php7-zlib \
  $PHPRUN_DEPS \
  && rm -fr /var/cache/apk/* \
  && ln -s /usr/bin/php7 /usr/bin/php \
  && php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php7 composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php7 -r "unlink('composer-setup.php');" \
  && php7 -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

EXPOSE 80

CMD ["php", "-t", "/srv", "-S", "0.0.0.0:80"]

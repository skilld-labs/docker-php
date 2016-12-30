FROM alpine:3.5
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
  && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === '61069fe8c6436a4468d0371454cf38a812e451a14ab1691543f25a9627b97ff96d8753d92a00654c21e2212a5ae1ff36') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
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

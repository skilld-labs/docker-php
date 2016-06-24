FROM alpine:edge
MAINTAINER Andy Postnikov <andypost@ya.ru>

# persistent / runtime deps
ENV PHPIZE_DEPS \
  autoconf \
  file \
  g++ \
  gcc \
  libc-dev \
  make \
  pkgconf \
  re2c

# add php7-xdebug if needed
ENV PHPRUN_DEPS \
  curl \
  mariadb-client \
  php7-xdebug \
  patch

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php7 \
  php7-apcu \
  php7-bcmath \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-gd \
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
  php7-xml \
  php7-zlib \
  && ln -s /usr/bin/php7 /usr/bin/php \
  && php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === 'bf16ac69bd8b807bc6e4499b28968ee87456e29a3894767b60c2d4dafa3d10d045ffef2aeb2e78827fa5f024fbe93ca2') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php7 composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer \
  && php7 -r "unlink('composer-setup.php');" \
  && php7 -r "copy('http://files.drush.org/drush.phar', '/usr/bin/drush');" \
  && chmod +x /usr/bin/drush \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  $PHPRUN_DEPS \
  && rm -rf /var/cache/apk/*

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

WORKDIR /srv

EXPOSE 80

CMD php -t /srv -S 0.0.0.0:80

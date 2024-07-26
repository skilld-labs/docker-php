FROM alpine:edge

ARG MOOSH=https://github.com/tmuras/moosh/archive/refs/tags/1.19.tar.gz
ARG COMPOSER_HASH=dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6

ENV PHPRUN_DEPS \
  curl \
  git \
  libxml2-utils \
  libxslt \
  make \
  mariadb-client \
  openssh-client \
  patch \
  postgresql-client \
  rsync \
  sqlite \
  wget

RUN set -eux \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && apk --update upgrade -a \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S web-group \
  && adduser -u 1000 -D -S -G web-group web-user \
  && mkdir -p /var/log/php82 && chown 1000:1000 /var/log/php82 \
  && apk add \
  php82 \
  php82-brotli \
  php82-pecl-apcu \
  php82-pecl-igbinary \
  php82-pecl-uploadprogress \
  php82-pecl-xdebug \
  php82-bcmath \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-exif \
  php82-fileinfo \
  php82-fpm \
  php82-gd \
  php82-gmp \
  php82-iconv \
  php82-intl \
  php82-mbstring \
  php82-opcache \
  php82-openssl \
  php82-pcntl \
  php82-pdo_mysql \
  php82-pdo_pgsql \
  php82-pdo_sqlite \
  php82-pgsql \
  php82-phar \
  php82-posix \
  php82-session \
  php82-simplexml \
  php82-soap \
  php82-sodium \
  php82-sqlite3 \
  php82-tokenizer \
  php82-xml \
  php82-xmlreader \
  php82-xmlwriter \
  php82-zip \
  $PHPRUN_DEPS \
  && ln -fs php82 /usr/bin/php \
\
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer2 \
  --2 \
  && ln -s composer2 /usr/bin/composer \
  && php -r "unlink('composer-setup.php');" \
\
  && wget $MOOSH -O /tmp/moosh.tgz \
  && mkdir /opt/moosh \
  && tar zxf /tmp/moosh.tgz -C /opt/moosh --strip-components 1 \
  && rm /tmp/moosh.tgz \
  && cd /opt/moosh \
  && composer install -o --prefer-dist --no-dev \
  && ln -s /opt/moosh/moosh.php /usr/bin/moosh \
  && rm -fr /var/cache/apk/* /root/.composer/cache/*

COPY php-fpm.conf /etc/php82/
COPY xx-moodle.ini /etc/php82/conf.d/xx-moodle.ini

#USER web-user
WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm82", "-F"]

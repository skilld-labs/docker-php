FROM alpine:edge

ENV COMPOSER_HASH dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6

ENV PHPRUN_DEPS \
  curl \
  git \
  libxml2-utils \
  libxslt \
  jq \
  make \
  mariadb-client \
  openssh-client \
  patch \
  rsync \
  sqlite \
  wget

RUN set -e \
  && apk --update upgrade \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && mkdir -p /var/www/html/web \
  && addgroup -g 1000 -S web-group \
  && adduser -u 1000 -D -S -G web-group web-user \
  && mkdir -p /var/log/php83 && chown 1000:1000 /var/log/php83 \
  && apk add --no-cache \
  php83 \
  php83-brotli \
  php83-pecl-apcu \
  php83-pecl-igbinary \
  php83-pecl-uploadprogress \
  php83-pecl-xdebug \
  php83-bcmath \
  php83-ctype \
  php83-curl \
  php83-dom \
  php83-exif \
  php83-fileinfo \
  php83-gd \
  php83-gmp \
  php83-iconv \
  php83-intl \
  php83-mbstring \
  php83-opcache \
  php83-openssl \
  php83-pcntl \
  php83-pdo_mysql \
  php83-pdo_pgsql \
  php83-pdo_sqlite \
  php83-pgsql \
  php83-phar \
  php83-posix \
  php83-session \
  php83-simplexml \
  php83-soap \
  php83-sodium \
  php83-sqlite3 \
  php83-tokenizer \
  php83-xml \
  php83-xmlreader \
  php83-xmlwriter \
  php83-zip \
  unit-php83 \
  $PHPRUN_DEPS \
  && ln -fs php83 /usr/bin/php \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === getenv('COMPOSER_HASH')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  --install-dir=/usr/bin \
  --filename=composer2 \
  --2 \
  && ln -s composer2 /usr/bin/composer \
  && php -r "unlink('composer-setup.php');" \
  && git clone --depth=1 https://github.com/tmuras/moosh.git \
  && cd moosh \
  && composer install \
  && ln -s $PWD/moosh.php /usr/bin/moosh \
  && rm -fr /var/cache/apk/*

COPY conf.json /var/lib/unit/

COPY xx-moodle.ini /etc/php83/conf.d/xx-moodle.ini

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80

CMD ["unitd", "--no-daemon", "--user", "web-user", "--group", "web-group", "--log", "/dev/stdout"]

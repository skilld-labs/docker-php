FROM alpine:edge

ARG COMPOSER_HASH=ed0feb545ba87161262f2d45a633e34f591ebb3381f2e0063c345ebea4d228dd0043083717770234ec00c5a9f9593792

ENV PHPRUN_DEPS="curl \
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
  wget"

RUN set -e \
  && apk --update upgrade \
  && echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && mkdir -p /var/www/html/web \
  && addgroup -g 1000 -S web-group \
  && adduser -u 1000 -D -S -G web-group web-user \
  && mkdir -p /var/log/php82 && chown 1000:1000 /var/log/php82 \
  && apk add --no-cache \
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
  s6-overlay \
  unit-php82 \
  $PHPRUN_DEPS \
  && ln -fs php82 /usr/bin/php \
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

COPY xx-moodle.ini /etc/php82/conf.d/xx-moodle.ini

COPY cron.sh /usr/local/bin/cron.sh
COPY crontab /etc/crontabs/root

COPY services /etc/services.d/

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/init"]

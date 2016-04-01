FROM alpine:3.3
MAINTAINER Harry Walter
MAINTAINER Andy Postnikov <andypost@ya.ru>

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update php7@testing php7-xml@testing php7-dom@testing php7-pdo_mysql@testing \
    php7-mcrypt@testing php7-curl@testing php7-json@testing php7-phar@testing php7-openssl@testing \
    php7-session@testing php7-gd@testing php7-opcache@testing php7-ctype@testing php7-zlib@testing \
    && rm -fr /var/cache/apk/* \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && curl -sS https://getcomposer.org/installer | php -- --filename=composer \
    --install-dir=/usr/bin --version=1.0.0-beta2 \
    && curl -sS "http://files.drush.org/drush.phar" -o /usr/bin/drush && chmod +x /usr/bin/drush

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

# todo build apcu
RUN apk add --no-cache php7-xdebug@testing mysql-client

WORKDIR /srv

EXPOSE 80

CMD php -t /srv -S 0.0.0.0:80

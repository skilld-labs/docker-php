FROM skilldlabs/php:73

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP-FPM 7.3 Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --no-cache \
  php7-fpm \
  php7-redis \
  php7-pecl-ssh2

COPY php-fpm.conf /etc/php7/

#USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

CMD ["php-fpm7", "-F"]

# syntax = docker/dockerfile:1.0-experimental
FROM skilldlabs/php:8

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP-FPM 7.4 Alpine for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN --mount=type=bind,source=keys,target=/var/cache/keys \
  --mount=type=bind,source=packages/testing,target=/var/cache/php8 \
  set -e \
  && cp /var/cache/keys/alpine-infra@*.pub /etc/apk/keys/ \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S www-data \
  && adduser -u 1000 -D -S -G www-data www-data \
  && apk add --no-cache -X /var/cache/php8 \
  php8-fpm \
  && rm /etc/apk/keys/alpine-infra@*.pub

COPY php-fpm.conf /etc/php8/

#USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

CMD ["php-fpm8", "-F"]

FROM skilldlabs/php:86

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP-FPM 8.6 Alpinelinux for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -e \
  && mkdir -p /var/www \
  && addgroup -g 1000 -S web-group \
  && adduser -u 1000 -D -S -G web-group web-user \
  && mkdir -p /var/log/php86 && chown 1000:1000 /var/log/php86 \
  && apk add --no-cache \
  php86-fpm

COPY php-fpm.conf /etc/php86/

#USER web-user
WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm86", "-F"]

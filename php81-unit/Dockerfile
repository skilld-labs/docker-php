FROM skilldlabs/php:81

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="Unit PHP 8.1 Alpinelinux for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -e \
  && mkdir -p /var/www/html/web \
  && addgroup -g 1000 -S www-skilld \
  && adduser -u 1000 -D -S -G www-skilld www-data \
  && apk add --no-cache \
  unit-php81

COPY conf.json /var/lib/unit/

#USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80

CMD ["unitd", "--no-daemon", "--user", "www-data", "--group", "www-skilld"]

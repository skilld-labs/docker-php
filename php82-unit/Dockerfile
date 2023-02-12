ARG PHPV=82

FROM skilldlabs/php:${PHPV}
ARG PHPV
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="Unit PHP 8.2 Alpinelinux for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

COPY conf.json /var/lib/unit/

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80

RUN set -e && \
  apk add --no-cache unit-php${PHPV} && \
  mkdir -p /var/www/html/web && \
  addgroup -g 1000 -S web-group && \
  adduser -u 1000 -D -S -G web-group web-user

CMD ["unitd", "--no-daemon", "--user", "web-user", "--group", "web-group"]

ARG PHPV=81

FROM skilldlabs/php:${PHPV}-unit

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="Unit PHP Alpinelinux for Drupal - git, composer, drush 8, sqlite, patch, nodejs, yarn" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -e && \
  apk add --no-cache nodejs yarn

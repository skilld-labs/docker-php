FROM alpine:3.11

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

# Use to build updated PHP version with https://gitlab.alpinelinux.org/alpine/aports
# then extract build artefacts in this directory.

COPY ./keys/*.pub /etc/apk/keys/
COPY ./packages/community /var/cache/php74

RUN set -e \
  && echo "/var/cache/php74" >> /etc/apk/repositories \

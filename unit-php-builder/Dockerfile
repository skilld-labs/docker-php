ARG PHPV=8

FROM alpine:edge AS builder
ARG PHPV
ARG UNITV=1.29.0
ENV CFLAGS="-Os -fomit-frame-pointer -D_LARGEFILE64_SOURCE"

RUN apk add --no-cache --upgrade --virtual .unit_build \
    -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    gcc openssl-dev make musl-dev patch php${PHPV}-dev php${PHPV}-embed

RUN mkdir /tmp/build && cd /tmp/build && \
  wget https://unit.nginx.org/download/unit-${UNITV}.tar.gz && tar -xzf unit-${UNITV}.tar.gz && \
  cd unit-${UNITV} && \
  ./configure \
    --prefix="/usr" \
    --state="/var/lib/unit" \
    --control="unix:/run/control.unit.sock" \
    --pid="/run/unit.pid" \
    --log="/dev/stdout" \
    --tmp=/tmp \
    --modules="/usr/lib/unit/modules" \
    --openssl \
  && \
  ./configure php --module=php${PHPV} --config=php-config${PHPV} && \
  make && make unitd-install php${PHPV}-install && \
  strip /usr/sbin/unitd /usr/lib/unit/modules/php${PHPV}.unit.so && \
  cd /tmp && rm -fr /build && apk del --no-network --purge .unit_build

FROM skilldlabs/php:${PHPV}
ARG PHPV
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="Unit PHP Alpinelinux for Drupal - git, composer, drush 8, sqlite, patch" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

COPY --from=builder /usr/sbin/unitd /usr/sbin/
COPY --from=builder /usr/lib/unit /usr/lib/unit
COPY conf.json /var/lib/unit/

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80

RUN set -e && \
  apk add --no-cache php${PHPV}-embed && \
  mkdir -p /var/www/html/web && \
  addgroup -g 1000 -S web-group && \
  adduser -u 1000 -D -S -G web-group web-user

CMD ["unitd", "--no-daemon", "--user", "web-user", "--group", "web-group"]

FROM skilldlabs/php:73-fpm

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP-dev 7.3 Alpine for Drupal - composer, drush, git, xhprof" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN apk add --update php7-pecl-xhprof \
  && apk del --purge php7-pecl-xdebug \
# build extra extensions
  && apk add --virtual .php-build \
#  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  php7-dev php7-pear make gcc g++ \
#  && sed -ie 's/-n//g' /usr/bin/pecl \
  && CFLAGS="-Os -fomit-frame-pointer -g -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fvisibility=hidden -Wall -Wno-strict-aliasing" \
  CPPFLAGS="$CFLAGS" LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
  pecl install xdebug-3.0.0RC1 \
  && echo ';zend_extension=xdebug.so' > /etc/php7/conf.d/50_xdebug.ini \
  && echo '; Configure mode https://3.xdebug.org/docs/all_settings#xdebug.mode' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.mode=debug' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.discover_client_host=1' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.client_port=9000' >> /etc/php7/conf.d/50_xdebug.ini \
  && echo 'xdebug.profiler_output_name=cachegrind.out.%p.%r' >> /etc/php7/conf.d/50_xdebug.ini \
  && strip /usr/lib/php7/modules/xdebug.so \
  && php7 -dzend_extension=xdebug -r 'xdebug_info();' \
# clean-up
  && apk del .php-build \
  && rm -fr /tmp/pear /usr/include /usr/share/pear /var/cache/apk/*

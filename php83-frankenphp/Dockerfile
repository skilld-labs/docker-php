######
# Base
######
ARG THE_BASE_IMAGE=ubuntu:noble

ARG PHP_FRA=8.3
ARG PHP_VERSION=8.3.12
ARG PHP_SHA256_HASH="f774e28633e26fc8c5197f4dae58ec9e3ff87d1b4311cbc61ab05a7ad24bd131"

ARG PHPIZE_DEPS="autoconf file g++ gcc make pkg-config re2c"

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ARG PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ARG PHP_LDFLAGS="-Wl,-O1 -pie"

FROM docker.io/dunglas/frankenphp:1-php${PHP_FRA} AS frankenphp

FROM ${THE_BASE_IMAGE} AS builder
ENV TERM=xterm DEBIAN_FRONTEND=noninteractive

#########
# Php build
######

# PHP Version
ARG PHP_VERSION
ARG PHP_URL="https://php.net/distributions/php-${PHP_VERSION}.tar.xz"
ARG PHP_SHA256_HASH
ENV PHP_VERSION=${PHP_VERSION}

ARG PHPIZE_DEPS

ARG PHP_CFLAGS
ARG PHP_LDFLAGS
ENV PHP_CFLAGS="$PHP_CFLAGS"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="$PHP_LDFLAGS"

RUN set -eux &&\
    echo 'APT::Install-Recommends "0";' >/etc/apt/apt.conf.d/99norecommends &&\
    apt-get update && apt-get install -qy --no-install-recommends \
        ca-certificates curl apt-utils xz-utils &&\
    \
    mkdir -p /usr/src &&\
    cd /usr/src &&\
    \
    curl -LS -o php.tar.xz "$PHP_URL" &&\
    \
    echo "$PHP_SHA256_HASH  php.tar.xz" | sha256sum -c &&\
    \
    buildDeps=" \
        libargon2-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libfreetype-dev \
        libicu-dev \
        libjpeg-turbo8-dev \
        libonig-dev \
        libkrb5-dev \
        zlib1g-dev \
        libpng-dev \
        libwebp-dev \
        libavif-dev \
        libsqlite3-dev \
        libpq-dev \
        libldap-dev \
        libsasl2-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libzip-dev \
        libncurses-dev \
    " &&\
    apt-get install -qy --no-install-recommends $PHPIZE_DEPS $buildDeps &&\
    rm -rf /var/lib/apt/lists/*

COPY ./conf/php/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php/php-cli.ini /usr/local/etc/php/php-cli.ini
COPY ./docker-php-* /usr/local/bin/

RUN set -xe &&\
    buildDir="/usr/src/php" &&\
    mkdir -p /usr/local/etc/php/conf.d &&\
    \
    mkdir "$buildDir" &&\
    tar -Jxf /usr/src/php.tar.xz -C "$buildDir" --strip-components=1 &&\
    cd "$buildDir" &&\
    CFLAGS="$PHP_CFLAGS" \
    CPPFLAGS="$PHP_CPPFLAGS" \
    LDFLAGS="$PHP_LDFLAGS" \
    ./configure \
        --with-config-file-path=/usr/local/etc/php \
        --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
        --enable-ftp=shared \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-curl \
        --with-libedit \
            --with-zlib \
            --with-kerberos \
            --with-openssl \
            --with-mysqli=shared \
            --with-pdo-mysql=shared \
            --with-pdo-sqlite=shared \
            --with-pdo-pgsql=shared \
            --with-readline \
            --with-freetype \
            --with-jpeg \
            --with-xsl \
            --with-tidy=shared \
            --with-gettext=shared \
            --enable-gd \
            --with-webp \
            --with-avif \
            --with-pear \
            --enable-sockets \
            --enable-exif \
            --with-zip \
            --enable-soap \
            --enable-sysvsem \
            --enable-sysvshm \
            --enable-shmop \
            --enable-pcntl \
            --enable-bcmath \
            --enable-xmlreader \
            --enable-intl \
            --enable-opcache \
        --enable-embed \
        --enable-zts \
        --disable-zend-signals \
        --enable-zend-max-execution-timers \
            --disable-cgi \
            --disable-phpdbg \
        --with-ldap=shared --with-ldap-sasl \
        --enable-intl=shared \
        --with-password-argon2 \
           &&\
    make -j "$(nproc)" &&\
    make install &&\
    cd / && rm -fr "$buildDir"

# install pecl extensions
RUN pecl channel-update pecl.php.net &&\
    pecl install APCu-5.1.23 \
        brotli \
        igbinary \
        msgpack \
        redis \
        uploadprogress \
        xdebug-3.3.2 \
        yaml-2.2.3 \
    &&\
    docker-php-ext-enable --ini-name 50_brotli.ini brotli &&\
    docker-php-ext-enable --ini-name 10_igbinary.ini igbinary &&\
    docker-php-ext-enable --ini-name 10_msgpack.ini msgpack &&\
    docker-php-ext-enable --ini-name 10_redis.ini redis &&\
    docker-php-ext-enable uploadprogress &&\
    echo ';zend_extension=xdebug' > /usr/local/etc/php/conf.d/50_xdebug.ini &&\
# stript .debug files out of executables
    echo '\
        for file in "$@"; do \
            objcopy --only-keep-debug "$file" "$file".debug; \
            strip --strip-debug --strip-unneeded "$file"; \
            objcopy --add-gnu-debuglink="$file".debug "$file"; \
            rm "$file".debug; \
        done' > /strip.sh; \
    sh strip.sh \
      /usr/local/bin/php \
      /usr/local/lib/libphp.so \
      $(php -r 'echo ini_get("extension_dir");')/*.so

COPY ./conf/php.ini /usr/local/etc/php/conf.d/xx-drupal.ini

COPY --from=frankenphp /usr/local/bin/frankenphp /usr/local/bin/


#########
# Php Setup
######

FROM ${THE_BASE_IMAGE}
ENV TERM=xterm DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local /usr/local

RUN set -xe &&\
    echo 'APT::Install-Recommends "0";' >/etc/apt/apt.conf.d/99norecommends ;\
    apt-get update &&\
    buildDeps=" \
        libargon2-1 \
        libedit2 \
        libfreetype6 \
        libicu74 \
        libjpeg-turbo8 \
        libonig5 \
        libkrb5-3 \
        libpng16-16 \
        zlib1g \
        libwebp7 \
        libavif16 \
        libaom3 \
        libsqlite3-0 \
        libpq5 \
        libldap2 \
        libsasl2-2 \
        libtidy5deb1 \
        libyaml-0-2 \
        libxml2 \
        libxslt1.1 \
        libzip4 \
        libncurses6 \
    " &&\
    runDeps=" \
        bzip2 \
        curl ca-certificates \
        default-mysql-client postgresql-client sqlite3 \
        git \
        graphicsmagick \
        patch \
        rsync \
        unzip \
        xz-utils \
    " &&\
    apt-get install -qy --no-install-recommends $buildDeps $runDeps &&\
    rm -rf /var/lib/apt/lists/*

# Install Composer, Drush
RUN curl -sSLo /tmp/composer-setup.php https://getcomposer.org/installer &&\
    curl -sSLo /tmp/composer-setup.sig https://composer.github.io/installer.sig &&\
    php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" &&\
    php /tmp/composer-setup.php --filename composer --install-dir /usr/local/bin &&\
    curl -sSLo /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/8.3.5/drush.phar &&\
    chmod +x /usr/local/bin/drush &&\
    /usr/local/bin/drush --version


######
# Webserver Setup
######

COPY ./conf/Caddyfile /etc/caddy/
COPY ./conf/php.ini /usr/local/etc/php/conf.d/xx-drupal.ini

RUN set -ex &&\
	ln -s /usr/local/etc/php /etc/php83 &&\
	ln -s bash /usr/bin/ash &&\
	\
	for dir in \
		/var/www/html \
		/var/www/.local/share/caddy \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "ubuntu:ubuntu" "$dir"; \
	done

ENV CADDY_ADMIN='0.0.0.0:2019'

ENV SERVER_NAME=':80'
EXPOSE 80

ENV CADDY_SERVER_EXTRA_DIRECTIVES='root * /var/www/html/web'
WORKDIR /var/www/html

USER ubuntu
CMD ["frankenphp", "run", "-c", "/etc/caddy/Caddyfile"]

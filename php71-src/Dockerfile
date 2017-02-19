FROM alpine:3.6

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -DSQLITE_MAX_VARIABLE_NUMBER=250000"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E

ENV PHP_VERSION 7.1.7
ENV PHP_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror" PHP_ASC_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="0d42089729be7b2bb0308cbe189c2782f9cb4b07078c8a235495be5874fff729" PHP_MD5="2e989bf0d8e64f25d2f678b45b5aa420"

ENV PHP_INI_DIR /etc/php

RUN set -xe; \
	\
	apk add --update \
		bison \
		ca-certificates \
		freetype \
		gmp \
		libjpeg-turbo \
		libmcrypt \
		libpng \
		libwebp \
		libxml2 \
		libcurl \
		libedit \
		libressl \
		mariadb-client \
		patch \
		sqlite; \
	\
	apk add --virtual .fetch-deps gnupg ; \
	\
	mkdir -p /tmp/src; \
	cd /tmp/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		rm -r "$GNUPGHOME"; \
	fi; \
	\
	apk del .fetch-deps; \
	\
	apk add --virtual .build-deps \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c \
		\
		curl-dev \
		libedit-dev \
		libxml2-dev \
		libressl-dev \
		mysql-dev \
		sqlite-dev \
		\
		freetype-dev \
		libjpeg-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libwebp-dev \
		\
		gmp-dev \
		libzip-dev \
		bzip2-dev \
		libtool; \
	\
	mkdir -p $PHP_INI_DIR/conf.d; \
	mkdir php; \
	tar xJf php.tar.xz -C php --strip-components=1; \
	cd php; \
	\
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS"; \
	./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
		--disable-phpdbg \
		--disable-cgi \
		--enable-fpm \
		--without-pear \
		\
		--enable-bcmath \
		--enable-ftp \
		--enable-mbstring \
		--enable-mysqlnd \
		\
		--enable-calendar \
		--enable-opcache \
		--enable-pcntl \
		--with-gmp \
		--with-mcrypt \
		--with-pdo-mysql \
		--with-readline \
		--enable-sockets \
		--enable-soap \
		--enable-zip \
		--with-bz2 \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
		--with-gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-webp-dir=/usr/include/; \
	make -j "$(getconf _NPROCESSORS_ONLN)" install; \
	make clean; \
	\
	cd / && rm -fr \
		/usr/local/include/php \
		/usr/local/php \
		/usr/local/lib/php/build \
		/var/cache/apk/* \
		/tmp/*; \
	\
	apk del .build-deps

COPY php.ini /etc/php7/conf.d/xx-drupal.ini

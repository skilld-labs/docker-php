#!/bin/sh

# Optionally enable Xdebug.
if [[ $PHP_XDEBUG_ENABLED = 1 ]]; then
  line="zend_extension=$(php-config --extension-dir)/xdebug.so"
  ini="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
	if ! grep -q "$line" "$ini" 2>/dev/null; then
    echo "$line" >> "$ini"
  fi
fi

docker-php-entrypoint

exec "$@"

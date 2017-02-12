#!/bin/sh

set -e

# Optionally enable Xdebug.
if [[ $PHP_XDEBUG_ENABLED = 1 ]]; then
  sed -i 's/^;zend_extension.*/zend_extension = xdebug.so/' /etc/php7/conf.d/xdebug.ini
fi

exec "$@"

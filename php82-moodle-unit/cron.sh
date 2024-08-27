#!/bin/sh
if [ -f /var/www/html/web/admin/cli/cron.php ]; then
  php /var/www/html/web/admin/cli/cron.php 1>&2
else
  echo "$(date +"%Y/%m/%d %H:%M:%S") [cron] Moodle cron script not found" 1>&2
fi

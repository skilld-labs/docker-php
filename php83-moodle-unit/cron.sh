#!/bin/sh

reduce_cron_verbosity() {
  while IFS= read -r line; do
    case "$line" in
      *"Continuing to check for tasks for"*) ;;
      "Ran 0 adhoc tasks found"*) ;;
      "Cron run completed correctly"*) ;;
      "..."*) ;;
      "") ;;
      *) echo "$(date +"%Y/%m/%d %H:%M:%S") [cron] $line" ;;
    esac
  done
}

if [ -f /var/www/html/web/admin/cli/cron.php ]; then
  echo "$(date +"%Y/%m/%d %H:%M:%S") [cron] Cron execution started" 1>&2
  php /var/www/html/web/admin/cli/cron.php | reduce_cron_verbosity 1>&2
  echo "$(date +"%Y/%m/%d %H:%M:%S") [cron] Cron execution finished" 1>&2
else
  echo "$(date +"%Y/%m/%d %H:%M:%S") [cron] Moodle cron script not found" 1>&2
fi

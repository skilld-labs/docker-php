#!/bin/sh

echo Drush updb
drush updb -vy

echo Drush clear cache
drush cc all

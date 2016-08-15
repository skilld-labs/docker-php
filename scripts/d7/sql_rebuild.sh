#!/bin/sh

echo Drush drop db
drush sql-drop

echo Drush upload db
drush sqlc < /src/latest.sql

echo Drush updb
drush updb -vy

echo Drush clear cache
drush cc all

#!/bin/sh

cp build/*.make.yml drupal/
# build site from makefiles
docker-compose exec web drush make profile.make.yml --prepare-install --overwrite -y
rm drupal/*.make.yml

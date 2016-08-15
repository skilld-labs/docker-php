#!/bin/sh

# include parse_yaml function
. scripts/parse_yaml.sh
# read yaml file
eval $(parse_yaml docker-compose.yml)

if [ "$services_web_environment_WORKFLOW" = "profile" ]; then
  cp build/*.make.yml drupal/
  docker-compose exec web drush make profile.make.yml --prepare-install --overwrite -y
  rm drupal/*.make.yml
fi;

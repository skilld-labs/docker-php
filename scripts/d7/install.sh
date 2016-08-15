#!/bin/sh

# include parse_yaml function
. scripts/parse_yaml.sh
# read yaml file
eval $(parse_yaml docker-compose.yml)

if [ "$services_web_environment_WORKFLOW" = "profile" ]; then
  docker-compose exec web drush si --account-pass=admin -y
fi;

if [ "$services_web_environment_WORKFLOW" = "sql" ]; then
  docker-compose exec web sh /scripts/d7/sql_rebuild.sh
fi;

#!/bin/sh

# include parse_yaml function
. scripts/parse_yaml.sh
# read yaml file
eval $(parse_yaml docker-compose.yml)


# remove old settings.php and create new.
docker-compose exec web chmod 777 sites/default/settings.php && rm sites/default/settings.php
docker-compose exec web cp sites/default/defaults.settings.php sites/default/settings.php

# include db settings.
docker-compose exec web sh -c "echo '\$databases = array(' >> sites/default/settings.php"
docker-compose exec web sh -c "echo \"'default' => array ('default' =>array ('database' => '$services_mysql_environment_MYSQL_DATABASE','username' => '$services_mysql_environment_MYSQL_USER','password' => '$services_mysql_environment_MYSQL_PASSWORD','host' => 'mysql','port' => '','driver' => 'mysql','prefix' => '')));\" >> sites/default/settings.php"


if [ "$services_web_environment_DRUPAL" = 7 ]; then
  # Include drupal7 install script
  ./scripts/d7/install.sh
fi;

if [ "$services_web_environment_DRUPAL" = 8 ]; then
  # Include drupal8 install script
  ./scripts/d8/install.sh
fi;

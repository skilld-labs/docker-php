#!/bin/sh

#docker-compose exec web composer require commerceguys/addressing commerceguys/intl commerceguys/zone

docker-compose exec web drush si --db-url=mysql://d8:d8@mysql/d8 --account-pass=admin -y

docker-compose exec web drush en default_content -y

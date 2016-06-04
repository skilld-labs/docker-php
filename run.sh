#!/bin/sh

# run as root

#docker-compose build web

# remove old containers
docker-compose stop
echo "y" |docker-compose rm

# prepare make files
mkdir -p drupal
cp build/*.make.yml drupal/

docker-compose up -d

# build site from makefiles
docker-compose exec web drush make profile.make.yml --prepare-install --overwrite -y
rm drupal/*.make.yml

# install Drupal
docker-compose exec web drush si --db-url=mysql://d8:d8@mysql/d8 --account-pass=admin -y

#docker run -e MYSQL_ROOT_PASSWORD=d8 -e MYSQL_DATABASE=d8 -e MYSQL_USER=d8 -e MYSQL_PASSWORD=d8 -v $(pwd)/db:/var/lib/mysql -d --name mysql percona:5.6

#docker run --name mailhog -p 1025:1025 -p 8025:8025 diyan/mailhog --help

#docker run --name d8 --link mysql:mysql -p 8081:80 -v $(pwd)/drupal:/srv -d php7

#!/bin/sh

drush dl drupal-8.1.x --dev --drupal-project-rename
cp .ht.router.php drupal/

docker-compose up -d

#docker run -e MYSQL_ROOT_PASSWORD=d8 -e MYSQL_DATABASE=proconsort -e MYSQL_USER=d8 -e MYSQL_PASSWORD=d8 -v $(pwd)/db:/var/lib/mysql -d --name mysql percona:5.6.27

#docker run --name mailhog -p 1025:1025 -p 8025:8025 diyan/mailhog --help

#docker run --name d8 --link mysql:mysql -p 8081:80 -v $(pwd):/srv -d php7

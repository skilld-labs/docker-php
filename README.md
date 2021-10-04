
[![](https://images.microbadger.com/badges/version/skilldlabs/php.svg)](http://microbadger.com/images/skilldlabs/php "Get your own version badge on microbadger.com") https://hub.docker.com/r/skilldlabs/php/

Use `run.sh` to fetch Drupal 9.3.dev and start containers.

Use `docker-compose stop` to stop containers and `docker-compose rm` to clean-up.

Local `db` directory stores mysql database files and `drupal` hold core.

## Hints

  For use drush directly from host machine you can specify next alias

  ```alias dr="cd /path/to/docker-copmose.yml && docker-compose exec web drush"```

  `php-xdebug` package included to all images but disabled.
  To enable just change `command` to enable the extension `-d zend_extension=xdebug.so`

## How to customize and extend this project

  If you want to add some packages you should:

  Example of php8-pdo_pgsql

  1) Create new container folder
  with own Dockerfile and extend this container from base one.

    ```
    FROM skilldlabs/php:8
    RUN apk add --no-cache php8-pdo_pgsql
    ```

  2) Change build reference in docker-compose.yml file

  ```yaml
    web:
      #build: php8/.
      # path to your custom container.
      build: php8-pgsql/.
  ```

#### XDebug support

To enable xdebug in PHP container add a `command` instruction.

Example usage:
  ```yaml
  version: "2"

    php:
      image: skilldlabs/php:8-fpm
      volumes:
        - ./docroot:/var/www/html
      command: php-fpm8 -F -d zend_extension=xdebug.so
  ```

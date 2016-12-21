Use `run.sh` to fetch Drupal 8.1-dev and start containers.

Use `docker-compose stop` to stop containers and `docker-compose rm` to clean-up.

Local `db` directory stores mysql database files and `drupal` hold core.

  ## Hints

  For use drush directly from host machine you can specify next alias

  ```alias dr="cd /path/to/docker-copmose.yml && docker-compose exec web drush"```

  `php-xdebug` package included to all images but disabled.
  To enable just change `command` to enable the extension `-d zend_extension=xdebug.so`

  ## How to customize and extend this project

  If you want to add some packages you should:

  Example of php7-pdo_pgsql

  1) Create new container folder
  with own Dockerfile and extend this container from base one.

    ```
    FROM skilldlabs/php:7
    RUN apk add --no-cache php7-pdo_pgsql
    ```

  2) Change build reference in docker-compose.yml file

  ```
    web:
      #build: php7/.
      # path to your custom container.
      build: php7-pgsql/.
  ```

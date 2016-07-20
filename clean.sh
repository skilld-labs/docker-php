#!/bin/sh

# remove old containers and start new ones.
docker-compose stop
echo "y" | docker-compose rm

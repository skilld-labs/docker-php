NAME = skilldlabs/php
TAGS = 56 56-xdebug 7 7-fpm 7-git 7-xdebug

.PHONY: all build push

all: build push

build:
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):php$$i \n\n"; cd php$$i; docker build -t $(NAME):$$i --no-cache --pull .; cd ..; done

push:
	docker push $(NAME)

NAME = skilldlabs/php
TAGS = 56 56-xdebug 7 7-fpm 7-git 7-xdebug

.PHONY: all build push

all: build push

build:
	set -e; for i in $(TAGS); do \
	  printf "\nBuilding $(NAME):php$$i \n\n"; \
	  cd php$$i; \
	  docker build -t $(NAME):$$i --no-cache --pull \
	    --build-arg VCS_REF="$(shell git rev-parse --short HEAD)" \
	    --build-arg BUILD_DATE='$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")' \
	    --build-arg VERSION="1.0" . ; \
	  cd ..; done

push:
	docker push $(NAME)

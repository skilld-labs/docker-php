NAME = skilldlabs/php
TAGS = 56 56-fpm 56-git 7 7-fpm 7-git 71 71-fpm 71-git

.PHONY: all build push

all: build push

build:
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):php$$i \n\n"; cd php$$i; docker build -t $(NAME):$$i --no-cache --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` .; cd ..; done

push:
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i \n\n"; docker push $(NAME):$$i; done

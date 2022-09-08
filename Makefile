NAME = skilldlabs/php
TAGS ?= 74 74-fpm 74-fpm-dev 8 8-fpm 81 81-fpm

COMPOSER_HASH ?= 55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae
DRUSH_VERSION ?= 8.4.11
DOCKER_BUILDKIT ?= 1

.PHONY: all build push

all: build push

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i \n\n"; cd php$$i; \
		DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(NAME):$$i \
		--no-cache --progress=plain \
		--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
		--build-arg DRUSH_VERSION=$(DRUSH_VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .; \
		cd ..; done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i \n\n"; docker push $(NAME):$$i; done

drush:
#	docker run --rm -u $(shell id -u):$(shell id -g) -v $(CURDIR)/drush8:/srv $(NAME):81 time sh slim-drush.sh
	docker run --rm -u $(shell id -u):$(shell id -g) -v $(CURDIR)/drush8:/srv $(NAME):81 time php -dphar.readonly=0 slim-drush.php
	cp drush8/drush.phar php8
	cp drush8/drush.phar php81

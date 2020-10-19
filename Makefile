NAME = skilldlabs/php
TAGS ?= 73 73-fpm 73-fpm-dev 73-fpm-extra1 74 74-fpm 74-fpm-dev

COMPOSER_HASH ?= c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394
DRUSH_VERSION ?= 8.4.5
DOCKER_BUILDKIT ?= 1

.PHONY: all build push

all: build push

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i \n\n"; cd php$$i; \
		DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(NAME):$$i --no-cache \
		--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
		--build-arg DRUSH_VERSION=$(DRUSH_VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .; \
		cd ..; done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i \n\n"; docker push $(NAME):$$i; done

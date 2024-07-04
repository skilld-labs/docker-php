NAME = skilldlabs/php
TAGS ?= 81 81-fpm 81-unit 82 82-fpm 82-unit 83 83-fpm 83-unit 84 84-fpm 84-unit

COMPOSER_HASH ?= dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6
DRUSH_VERSION ?= 8.4.12
DOCKER_BUILDKIT ?= 1
PLATFORM ?= linux/amd64,linux/arm64

.PHONY: all build push prepare

all: build push

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i \n\n"; cd php$$i; \
		docker buildx build -t $(NAME):$$i \
		--platform $(PLATFORM) \
		--no-cache --progress=plain --push \
		--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
		--build-arg DRUSH_VERSION=$(DRUSH_VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .; \
		cd ..; done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i \n\n"; docker push $(NAME):$$i; done

unit:
	make -C unit-php-builder/dev build

prepare:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --use

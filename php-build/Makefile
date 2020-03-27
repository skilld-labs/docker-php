NAME = skilldlabs/php
TAGS ?= 8 8-fpm

COMPOSER_HASH ?= 8a6138e2a05a8c28539c9f0fb361159823655d7ad2deecb371b04a83966c61223adc522b0189079e3e9e277cd72b8897
DRUSH_VERSION ?= 8.4.1
DOCKER_BUILDKIT ?= 1

.PHONY: all build push

all: build

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i \n\n"; cd $$i; \
		DOCKER_BUILDKIT=1 docker build -t $(NAME):$$i --no-cache \
		--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
		--build-arg DRUSH_VERSION=$(DRUSH_VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		-f Dockerfile ../context; \
		cd ..; done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i \n\n"; docker push $(NAME):$$i; done

package:
	@echo "Packaging artefacts to image"
	docker build -t $(NAME):8-build --no-cache \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		-f Dockerfile context; \

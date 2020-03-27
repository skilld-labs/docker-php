NAME = skilldlabs/php
TAGS ?= 81 81-fpm

COMPOSER_HASH ?= 756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3
DRUSH_VERSION ?= 8.4.8
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
	docker build -t $(NAME):81-build --no-cache \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		-f Dockerfile context; \

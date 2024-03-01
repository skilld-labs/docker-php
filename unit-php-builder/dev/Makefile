NAME = skilldlabs/php
TAGS ?= 82 83

DOCKER_BUILDKIT ?= 1
PLATFORM ?= linux/amd64,linux/arm64

.PHONY: all build push

all: build

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i-unit-dev \n\n"; \
		docker buildx build -t $(NAME):$$i-unit-dev \
		--platform $(PLATFORM) \
		--pull --push \
		--no-cache --progress=plain \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg PHPV=$$i .; \
		done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i-unit-dev \n\n"; docker push $(NAME):$$i-unit-dev; done

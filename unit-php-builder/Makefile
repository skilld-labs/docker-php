NAME = skilldlabs/php
TAGS ?= 8 81 82

DOCKER_BUILDKIT ?= 1

.PHONY: all build push

all: build push

build:
	@echo "Building images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nBuilding $(NAME):$$i-unit \n\n"; \
		DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(NAME):$$i-unit \
		--no-cache --progress=plain \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg PHPV=$$i .; \
		done

push:
	@echo "Pushing images for tags: $(TAGS)"
	set -e; for i in $(TAGS); do printf "\nPushing $(NAME):$$i-unit \n\n"; docker push $(NAME):$$i-unit; done

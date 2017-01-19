FROM skilldlabs/php:7

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="docker-php" \
  org.label-schema.description="PHP Alpine for Drupal - composer & drush" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/docker-php" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN apk add --no-cache \
  sqlite \
  git \
  && curl -o /usr/bin/gitlab-ci-multi-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/master/binaries/gitlab-ci-multi-runner-linux-amd64 \
  && chmod +x /usr/bin/gitlab-ci-multi-runner \
  && ln -s /usr/bin/gitlab-ci-multi-runner /usr/bin/gitlab-runner \
  && ln -s /usr/bin/gitlab-ci-multi-runner /usr/bin/gitlab-runner-helper

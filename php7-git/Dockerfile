FROM skilldlabs/php:7
MAINTAINER Andy Postnikov <andypost@ya.ru>

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  sqlite \
  git \
  && curl -o /usr/bin/gitlab-ci-multi-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/master/binaries/gitlab-ci-multi-runner-linux-amd64 \
  && chmod +x /usr/bin/gitlab-ci-multi-runner \
  && ln -s /usr/bin/gitlab-ci-multi-runner /usr/bin/gitlab-runner \
  && ln -s /usr/bin/gitlab-ci-multi-runner /usr/bin/gitlab-runner-helper

#!/bin/sh

#  This script will build the images and push them if an argument is provided

set -e

if [ -n "$1" ]; then
  DOCKER_REPOSITORY="$1:"
fi

cd $(dirname $0)

for VERSION in "9.5" "9.6" "10" "11" "12"; do
    DOCKER_TAG=$DOCKER_REPOSITORY$VERSION  # will push to :latest
    DOCKER_TAG_DATE=$DOCKER_TAG-$(date +%Y-%m-%d)
    docker build --build-arg DOCKER_POSTGRES_VERSION="$VERSION" --tag "$DOCKER_TAG" --tag "$DOCKER_TAG_DATE" .
    if [ -n "$DOCKER_REPOSITORY" ]; then
      docker push "$DOCKER_TAG"
      docker push "$DOCKER_TAG_DATE"
    fi
done

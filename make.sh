#!/bin/bash

# This script will generate the Dockerfiles
set -e

cd $(dirname $0)

for VERSION in "9.5" "9.6"; do
    mkdir -p $VERSION
    cp -r templates/files/* $VERSION
    sed -e 's/\$DOCKER_POSTGRES_VERSION/'$VERSION'/g' "templates/Dockerfile-postgresql-9.template" > $VERSION/Dockerfile
done

for VERSION in "10" "10.5" "10.6" "11" "11.1"; do
    mkdir -p $VERSION
    cp -r templates/files/* $VERSION
    sed -e 's/\$DOCKER_POSTGRES_VERSION/'$VERSION'/g' "templates/Dockerfile-postgresql.template" > $VERSION/Dockerfile
done

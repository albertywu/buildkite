#!/bin/bash

set -ex

. utils.sh

cat ~/.docker/config.json

echo "---"
pwd
echo "---"

# volume-mount a yarn cache dir, to prevent excessive uNPM calls
util_install_yarn_cache_tarball $PROJECT

# get the yarn cache directory inside the docker container
YARN_CACHE_DIR=$(docker run --rm "$BUILD_IMAGE" bash -c 'yarn cache dir')

docker run -v ${PWD}/.yarn_cache:$YARN_CACHE_DIR -i --rm $BUILD_IMAGE bash <<CMD
  jazelle ci --cwd $PROJECT
  jazelle yarn cover --cwd $PROJECT
CMD

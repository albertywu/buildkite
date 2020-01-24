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

HAS_COVER=$(docker run -i --rm $BUILD_IMAGE bash -c "jq -e '.scripts.cover' $PROJECT/package.json > /dev/null && echo true || echo false")
# If no cover script in package.json, return immediately
if [ $HAS_COVER = false ]; then
  echo "scripts.cover missing in $PROJECT/package.json. Exiting without calculating coverage data."
  exit 0
fi

docker run -v ${PWD}/.yarn_cache:$YARN_CACHE_DIR -i --rm $BUILD_IMAGE bash <<CMD
  jazelle ci --cwd $PROJECT
  jazelle yarn cover --cwd $PROJECT
CMD

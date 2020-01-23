#!/bin/bash

set -ex

. utils.sh

cat ~/.docker/config.json

IMAGE=027047743804.dkr.ecr.us-west-1.amazonaws.com/web-code:jenkins-plan-web-monorepo-9786
PACKAGE=$1

echo "---"
pwd
echo "---"

# volume-mount a yarn cache dir, to prevent excessive uNPM calls
util_install_yarn_cache_tarball $PACKAGE

# get the yarn cache directory inside the docker container
YARN_CACHE_DIR=$(docker run --rm "$IMAGE" bash -c 'yarn cache dir')

docker run -v ${PWD}/.yarn_cache:$YARN_CACHE_DIR -i --rm $IMAGE bash <<CMD
  jazelle ci --cwd $PACKAGE
  jazelle lint --cwd $PACKAGE
CMD

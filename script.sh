#!/bin/bash

set -eo pipefail

. utils.sh

cat ~/.docker/config.json

IMAGE=027047743804.dkr.ecr.us-west-1.amazonaws.com/web-code:jenkins-plan-web-monorepo-9786
PACKAGE=projects/example-trips-viewer-fusion

# volume-mount a yarn cache dir, to prevent excessive uNPM calls
util_install_yarn_cache_tarball $PACKAGE

docker run -i --rm $IMAGE bash <<CMD
  jazelle ci --cwd $PACKAGE
  jazelle lint --cwd $PACKAGE
CMD

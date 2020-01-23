#!/bin/bash

set -eo pipefail

cat ~/.docker/config.json

IMAGE=027047743804.dkr.ecr.us-west-1.amazonaws.com/web-code:jenkins-plan-web-monorepo-9786
PACKAGE=projects/example-trips-viewer-fusion

docker run -i --rm $IMAGE bash <<CMD
  jazelle ci --cwd $PACKAGE
  jazelle lint --cwd $PACKAGE
CMD

#!/bin/bash

set -eo pipefail

cat ~/.docker/config.json

CMD=lint
IMAGE=027047743804.dkr.ecr.us-west-1.amazonaws.com/web-code:jenkins-plan-web-monorepo-9786
PACKAGE=projects/example-trips-viewer-fusion

mkdir -p web-code-source && chmod a+w web-code-source
# pull out ci code and $PACKAGE code from the docker build image, and store in local /web-code-source folder
docker run \
  -v ${PWD}/web-code-source:/web-code-source \
  -i \
  --rm \
  -u 0 \
  $IMAGE bash <<CMD
rm -rf /web-code-source/*
cp -rf /web-code/ci /web-code-source
mkdir -p /web-code-source/$(dirname $PACKAGE)
mkdir -p /web-code-source/projects
cp -rf /web-code/projects/monorepo-tools /web-code-source/projects
cp -rf /web-code/$PACKAGE /web-code-source/$PACKAGE
echo Changing owner of /web-code-source from \$(id -u):\$(id -g) to $(id -u):$(id -g)
chown -R $(id -u):$(id -g) /web-code-source
echo "chown DONE"
CMD

cd web-code-source
ls -al
. ci/helpers.sh
. projects/monorepo-tools/scripts/utils.sh

case $CMD in
  "lint")
    run_docker $IMAGE $PACKAGE projects/monorepo-tools/scripts/lint.sh
    ;;
  "flow")
    run_docker $IMAGE $PACKAGE projects/monorepo-tools/scripts/flow.sh
    ;;
  "cover")
    run_docker $IMAGE $PACKAGE projects/monorepo-tools/scripts/cover.sh
    ;;
  "integration")
    retry_flaky_alert "Flaky integration test detected: $BUILD_URL" \
      2 . projects/monorepo-tools/scripts/integration.sh $IMAGE
    ;;
  "bundle_size")
    run_docker $IMAGE $PACKAGE projects/monorepo-tools/scripts/bundle_size.sh
    ;;
  *) exit_with_error "Unknown command: '$CMD'" ;;
esac
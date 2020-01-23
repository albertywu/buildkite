#!/bin/bash

set -eo pipefail

cat ~/.docker/config.json

docker run -it --rm 027047743804.dkr.ecr.us-west-1.amazonaws.com/web-code:jenkins-plan-web-monorepo-9786 bash -c 'ls -al'

echo "BUILDKITE_PARALLEL_JOB: $BUILDKITE_PARALLEL_JOB"
echo "BUILDKITE_PARALLEL_JOB_COUNT: $BUILDKITE_PARALLEL_JOB_COUNT"
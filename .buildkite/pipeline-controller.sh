function generate_pipeline() {
  echo "steps:"

  for project_path in $PROJECTS ; do (
    project_name=$(basename "$project_path");

    echo "  - trigger: 'web-code-tests'";
    echo "    label: '$project_name'";
    echo "    build:";
    echo "      branch: '\${BUILDKITE_BRANCH}'";
    echo "      commit: '\${BUILDKITE_COMMIT}'";
    echo "      message: '\${BUILDKITE_MESSAGE}'";
    echo "      env:";
    echo "        PROJECT: '$project_path'";
    echo "        BUILD_IMAGE: '\${BUILD_IMAGE}'";
    echo "        BUILD_IMAGE_INTEGRATION: '\${BUILD_IMAGE_INTEGRATION}'";
    echo "        BUILD_TAG: '\${BUILD_TAG}'";
    echo "        CI_VERSION: '\${CI_VERSION}'";
  ); done;
}

generate_pipeline | buildkite-agent pipeline upload

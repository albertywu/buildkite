# usage:
# if is_in_list "$list" "$item"; then ...
function is_in_list() {
  local list=$1
  local item=$2

  if [[ " $list " =~ .*\ $item\ .* ]]
    then return 0
    else return 1
  fi
}

function generate_pipeline() {
  echo "steps:"

  for project_path in $PROJECTS ; do (
    project_name=$(basename "$project_path");

    echo "  - trigger: 'web-code-runner'";
    echo "    label: '$project_name'";
    echo "    build:";
    echo "      branch: '\${BUILDKITE_BRANCH}'";
    echo "      commit: '\${BUILDKITE_COMMIT}'";
    echo "      message: '[$project_name] \${BUILDKITE_MESSAGE}'";
    echo "      env:";
    echo "        PROJECT: '$project_path'";
    echo "        BUILD_IMAGE: '\${BUILD_IMAGE}'";
    echo "        BUILD_IMAGE_INTEGRATION: '\${BUILD_IMAGE_INTEGRATION}'";
    echo "        BUILD_TAG: '\${BUILD_TAG}'";
    echo "        CI_VERSION: '\${CI_VERSION}'";
    if is_in_list "$PROJECTS_COVER_DISABLED" "$PROJECT"
      then echo "        COVER_DISABLED: 'true'";
    fi
    echo "        WEB_CODE_AWS_KEY_ID: '\${WEB_CODE_AWS_KEY_ID}'";
    echo "        WEB_CODE_AWS_ACCESS_KEY: '\${WEB_CODE_AWS_ACCESS_KEY}'";
  ); done;
}

generate_pipeline | buildkite-agent pipeline upload

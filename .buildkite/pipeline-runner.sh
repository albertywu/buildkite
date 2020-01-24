function generate_pipeline() {
  local job_types="bundle-size cover flow integration lint"
  local project_name=$(basename "$PROJECT");

  echo "steps:"
  for job_type in $job_types ; do (
    echo "  - label: '$project_name'";
    echo "    commands:";
    echo "    - 'echo $project_name $job_type'";
    echo "    timeout_in_minutes: 15";
    echo "    agents:";
    echo "      queue: web-code-default";
  ); done;
}

generate_pipeline | buildkite-agent pipeline upload

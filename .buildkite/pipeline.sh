function generate_pipeline() {
  echo "steps:"

  for project in $PROJECTS ; do (
    project_name=$(basename "$project");

    echo "  - label: '$project_name %n'";
    echo "    commands:";
    echo "    - 'echo $project_name $$BUILDKITE_PARALLEL_JOB'";
    echo "    timeout_in_minutes: 15";
    echo "    parallelism: 5";
    echo "    agents:";
    echo "      queue: web-code-default";
  ); done;
}

generate_pipeline | buildkite-agent pipeline upload

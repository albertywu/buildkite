function generate_pipeline() {
  local job_types="bundle-size cover flow integration lint"

  for diff_id in $DIFF_IDS; do
    echo $diff_id
  done

  echo "steps:"

  for project in $PROJECTS ; do (
    project_name=$(basename "$project");

    for job_type in $job_types ; do (
      echo "  - label: '$job_type'";
      echo "    commands:";
      echo "    - 'echo $project_name ${job_type}!'";
      echo "    timeout_in_minutes: 15";
      # echo "    parallelism: 5";
      echo "    concurrency: 5";
      echo "    concurrency_group: '$project_name'";
      echo "    agents:";
      echo "      queue: web-code-default";
    ); done;
  ); done;
}

generate_pipeline | buildkite-agent pipeline upload

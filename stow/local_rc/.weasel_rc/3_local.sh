#!/bin/bash

eval "$(dd-gitsign load-key)"

complete -o nospace -C /Users/gregoire.roussel/.config/tfenv/versions/1.11.1/terraform terraform

# based on bin/submit_to_cluster
function apd_get_api_base {
  aws_region="us-west-2"
  team_id=60693115
  out="$(aws-vault exec smp -- aws --region "${aws_region}" \
        lambda get-function-url-config \
        --function-name "${team_id}-curta-api" \
        --query FunctionUrl \
        --output text)"
  echo "---"
  echo "--api-base $out"
}

function sync_job_local {
  job_id=${1:?"missing job id"}
  aws-vault exec smp -- ~/dd/single-machine-performance/target/debug/smp debug job download-all-files --team-name gr-dev --job-id "$job_id"
}

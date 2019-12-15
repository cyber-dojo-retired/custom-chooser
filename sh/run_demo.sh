#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly PORT=80

export $(docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env')

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

json_curl()
{
  URL=${1}
  DISPLAY_NAME='Java Countdown, Round 1'
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --header 'Accept: application/json' \
    --silent \
    -X POST \
    "http://$(ip_address):${PORT}/${URL}" \
      | jq .id
}

echo
echo Json
printf "custom/create_kata  => $(json_curl custom/create_kata)\n"
printf "custom/create_group => $(json_curl custom/create_group)\n"
echo 'Deprecated Json (nginx redirect)'
printf ".../save_individual_json => $(json_curl setup_custom_start_point/save_individual_json)\n"
printf ".../save_group_json      => $(json_curl setup_custom_start_point/save_group_json)\n"
echo

#open "http://$(ip_address):${PORT}/custom/index?for=kata"

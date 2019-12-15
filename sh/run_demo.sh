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

curl_json_format_create()
{
  TYPE=${1}
  DISPLAY_NAME='Java Countdown, Round 1'
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --header 'Accept: application/json' \
    --silent \
    -X POST \
    "http://$(ip_address):${PORT}/custom/create_${TYPE}" \
      | jq .id
}

printf "\nCreate kata  :$(curl_json_format_create kata)"
printf "\nCreate group :$(curl_json_format_create group)"
echo

#open "http://$(ip_address):${PORT}/custom/index?for=kata"

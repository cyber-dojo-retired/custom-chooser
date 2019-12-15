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
      | jq -r .id
}

http_curl()
{
  URL=${1}
  LOG=/tmp/custom.log
  DISPLAY_NAME='Java Countdown, Round 1'
  X_DISPLAY_NAME='Java%20Countdown%2C%20Round%201'
  curl  \
    --header 'Accept: text/html' \
    --silent \
    --verbose \
    -X POST \
    "http://$(ip_address):${PORT}/${URL}?display_name=${X_DISPLAY_NAME}" \
     > ${LOG} 2>&1
  grep --quiet 302 ${LOG}          # HTTP/1.1 302 Moved Temporarily
  LOCATION=$(grep Location ${LOG}) # Location: http://192.168.99.100/kata/edit/mzCS1h
  echo -n ${LOCATION:(-6)}
}

echo
echo HTTP
printf "custom/create_kata  => $(http_curl custom/create_kata)\n"
printf "custom/create_group => $(http_curl custom/create_group)\n"

echo
echo JSON
printf "custom/create_kata  => $(json_curl custom/create_kata)\n"
printf "custom/create_group => $(json_curl custom/create_group)\n"

echo
OLD_CONTROLLER=setup_custom_start_point
echo "Deprecated (nginx redirect) ${OLD_CONTROLLER}/..."
echo HTTP
printf ".../save_individual_json => $(http_curl ${OLD_CONTROLLER}/save_individual_json)\n"
printf ".../save_group_json      => $(http_curl ${OLD_CONTROLLER}/save_group_json)\n"

echo
echo JSON
printf ".../save_individual_json => $(json_curl ${OLD_CONTROLLER}/save_individual_json)\n"
printf ".../save_group_json      => $(json_curl ${OLD_CONTROLLER}/save_group_json)\n"
echo

open "http://$(ip_address):${PORT}/custom/index?for=kata"

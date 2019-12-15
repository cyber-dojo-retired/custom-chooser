#!/bin/bash
set -e

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
readonly IP_ADDRESS=$(ip_address)
readonly PORT=80
readonly DISPLAY_NAME='Java Countdown, Round 1'
readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
export $(docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env')
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json()
{
  local -r TYPE=${1}
  local -r ROUTE=${2}
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --fail \
    --header 'Accept: application/json' \
    --silent \
    -X ${TYPE} \
    "http://${IP_ADDRESS}:${PORT}/${ROUTE}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_http_302()
{
  local -r TYPE=${1}
  local -r ROUTE=${2}
  local -r LOG=/tmp/custom.log
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --fail \
    --header 'Accept: text/html' \
    --silent \
    --verbose \
    -X ${TYPE} \
    "http://${IP_ADDRESS}:${PORT}/${ROUTE}" \
     > ${LOG} 2>&1
  grep --quiet 302 ${LOG}             # HTTP/1.1 302 Moved Temporarily
  LOCATION=$(grep Location ${LOG})    # Location: http://192.168.99.100/kata/edit/mzCS1h
  printf "%s" "kata${LOCATION#*kata}" # /kata/edit/mzCS1h
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api()
{
  local -r CONTROLLER=custom
  printf "\n"
  printf "New api /${CONTROLLER}/...\n"
  printf "\tGET 200 .../alive? => $(curl_json GET ${CONTROLLER}/alive?)\n"
  printf "\tGET 200 .../ready? => $(curl_json GET ${CONTROLLER}/ready?)\n"
  printf "\tGET 200 .../sha    => $(curl_json GET ${CONTROLLER}/sha)\n"
  printf "\n"
  printf "\tPOST HTTP 302 .../create_kata  => $(curl_http_302 POST ${CONTROLLER}/create_kata)\n"
  printf "\tPOST HTTP 302 .../create_group => $(curl_http_302 POST ${CONTROLLER}/create_group)\n"
  printf "\n"
  printf "\tPOST JSON 200 .../create_kata  => $(curl_json POST ${CONTROLLER}/create_kata)\n"
  printf "\tPOST JSON 200 .../create_group => $(curl_json POST ${CONTROLLER}/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_api()
{
  local -r CONTROLLER=setup_custom_start_point
  printf "\n"
  printf "Deprecated api (nginx redirect) /${CONTROLLER}/...\n"
  printf "\tPOST HTTP 302 .../save_individual => $(curl_http_302 POST ${CONTROLLER}/save_individual)\n"
  printf "\tPOST HTTP 302 .../save_group      => $(curl_http_302 POST ${CONTROLLER}/save_group)\n"
  printf "\n"
  printf "\tPOST JSON 200 .../save_individual_json => $(curl_json POST ${CONTROLLER}/save_individual_json)\n"
  printf "\tPOST JSON 200 .../save_group_json      => $(curl_json POST ${CONTROLLER}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api
demo_deprecated_api
printf "\n"
open "http://$(ip_address):${PORT}/custom/index?for=kata"

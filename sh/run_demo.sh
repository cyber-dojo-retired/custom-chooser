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
  grep --quiet 302 ${LOG}             # eg HTTP/1.1 302 Moved Temporarily
  LOCATION=$(grep Location ${LOG})    # eg Location: http://192.168.99.100/kata/edit/mzCS1h
  printf "%s" "kata${LOCATION#*kata}" # eg /kata/edit/mzCS1h
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api()
{
  local -r CONTROLLER=custom
  printf "\n"
  printf "API /${CONTROLLER}/...\n"
  printf "\t200 GET .../alive? => $(curl_json GET ${CONTROLLER}/alive?)\n"
  printf "\t200 GET .../ready? => $(curl_json GET ${CONTROLLER}/ready?)\n"
  printf "\t200 GET .../sha    => $(curl_json GET ${CONTROLLER}/sha)\n"
  printf "\n"
  printf "\t302 POST HTTP .../create_kata  => $(curl_http_302 POST ${CONTROLLER}/create_kata)\n"
  printf "\t302 POST HTTP .../create_group => $(curl_http_302 POST ${CONTROLLER}/create_group)\n"
  printf "\n"
  printf "\t200 POST JSON .../create_kata  => $(curl_json POST ${CONTROLLER}/create_kata)\n"
  printf "\t200 POST JSON .../create_group => $(curl_json POST ${CONTROLLER}/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_api()
{
  local -r CONTROLLER=setup_custom_start_point
  printf "\n"
  printf "Deprecated API (nginx redirect) /${CONTROLLER}/...\n"
  printf "\t302 POST HTTP .../save_individual => $(curl_http_302 POST ${CONTROLLER}/save_individual)\n"
  printf "\t302 POST HTTP .../save_group      => $(curl_http_302 POST ${CONTROLLER}/save_group)\n"
  printf "\n"
  printf "\t200 POST JSON .../save_individual_json => $(curl_json POST ${CONTROLLER}/save_individual_json)\n"
  printf "\t200 POST JSON .../save_group_json      => $(curl_json POST ${CONTROLLER}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
open_index_in_browser()
{
  printf "\n"
  open "http://${IP_ADDRESS}:${PORT}/custom/index?for=kata"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api
demo_deprecated_api
open_index_in_browser

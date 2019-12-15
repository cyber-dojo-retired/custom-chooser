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
json_curl()
{
  local -r ROUTE=${1}
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --header 'Accept: application/json' \
    --silent \
    -X POST \
    "http://${IP_ADDRESS}:${PORT}/${ROUTE}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
http_curl()
{
  local -r ROUTE=${1}
  local -r LOG=/tmp/custom.log
  curl  \
    --data-urlencode "display_name=${DISPLAY_NAME}" \
    --header 'Accept: text/html' \
    --silent \
    --verbose \
    -X POST \
    "http://${IP_ADDRESS}:${PORT}/${ROUTE}" \
     > ${LOG} 2>&1
  grep --quiet 302 ${LOG}             # HTTP/1.1 302 Moved Temporarily
  LOCATION=$(grep Location ${LOG})    # Location: http://192.168.99.100/kata/edit/mzCS1h
  printf "%s" "kata${LOCATION#*kata}" # /kata/edit/mzCS1h
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_new_routes()
{
  printf "\n"
  printf "New routes /custom/...\n"
  printf "\tHTTP .../create_kata  => $(http_curl custom/create_kata)\n"
  printf "\tHTTP .../create_group => $(http_curl custom/create_group)\n"
  printf "\n"
  printf "\tJSON .../create_kata  => $(json_curl custom/create_kata)\n"
  printf "\tJSON .../create_group => $(json_curl custom/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_routes()
{
  local -r OLD_CONTROLLER=setup_custom_start_point
  printf "\n"
  printf "Deprecated (nginx redirect) ${OLD_CONTROLLER}/...\n"
  printf "\tHTTP .../save_individual => $(http_curl ${OLD_CONTROLLER}/save_individual)\n"
  printf "\tHTTP .../save_group      => $(http_curl ${OLD_CONTROLLER}/save_group)\n"
  printf "\n"
  printf "\tJSON .../save_individual_json => $(json_curl ${OLD_CONTROLLER}/save_individual_json)\n"
  printf "\tJSON .../save_group_json      => $(json_curl ${OLD_CONTROLLER}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_new_routes
demo_deprecated_routes
printf "\n"
open "http://$(ip_address):${PORT}/custom/index?for=kata"

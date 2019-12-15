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
#"${SH_DIR}/build_docker_images.sh"
#"${SH_DIR}/docker_containers_up.sh"

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
curl_http()
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
demo_new_api()
{
  printf "\n"
  printf "New api /custom/...\n"
  printf "\tGET HTTP .../alive? => $(curl_json GET custom/alive?)\n"
  printf "\tGET HTTP .../ready? => $(curl_json GET custom/ready?)\n"
  printf "\tGET HTTP .../sha    => $(curl_json GET custom/sha)\n"
  printf "\n"
  printf "\tPOST HTTP .../create_kata  => $(curl_http POST custom/create_kata)\n"
  printf "\tPOST HTTP .../create_group => $(curl_http POST custom/create_group)\n"
  printf "\n"
  printf "\tPOST JSON .../create_kata  => $(curl_json POST custom/create_kata)\n"
  printf "\tPOST JSON .../create_group => $(curl_json POST custom/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_api()
{
  local -r OLD_CONTROLLER=setup_custom_start_point
  printf "\n"
  printf "Deprecated api (nginx redirect) /${OLD_CONTROLLER}/...\n"
  printf "\tPOST HTTP .../save_individual => $(curl_http POST ${OLD_CONTROLLER}/save_individual)\n"
  printf "\tPOST HTTP .../save_group      => $(curl_http POST ${OLD_CONTROLLER}/save_group)\n"
  printf "\n"
  printf "\tPOST JSON .../save_individual_json => $(curl_json POST ${OLD_CONTROLLER}/save_individual_json)\n"
  printf "\tPOST JSON .../save_group_json      => $(curl_json POST ${OLD_CONTROLLER}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_new_api
demo_deprecated_api
printf "\n"
open "http://$(ip_address):${PORT}/custom/index?for=kata"

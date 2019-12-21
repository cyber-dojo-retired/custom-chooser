#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"
source ${SH_DIR}/ip_address.sh
readonly IP_ADDRESS=$(ip_address)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { printf 80; }
display_name() { printf 'Java Countdown, Round 1'; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json()
{
  local -r TYPE=${1}
  local -r ROUTE=${2}
  curl  \
    --data-urlencode "display_name=$(display_name)" \
    --fail \
    --header 'Accept: application/json' \
    --silent \
    -X ${TYPE} \
    "http://${IP_ADDRESS}:$(port)/${ROUTE}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_http_302()
{
  local -r TYPE=${1}
  local -r ROUTE=${2}
  local -r LOG=/tmp/custom.log
  curl  \
    --data-urlencode "display_name=$(display_name)" \
    --fail \
    --header 'Accept: text/html' \
    --silent \
    --verbose \
    -X ${TYPE} \
    "http://${IP_ADDRESS}:$(port)/${ROUTE}" \
     > ${LOG} 2>&1
  grep --quiet 302 ${LOG}          # eg HTTP/1.1 302 Moved Temporarily
  LOCATION=$(grep Location ${LOG}) # eg Location: http://192.168.99.100/kata/edit/mzCS1h
  printf "kata${LOCATION#*kata}"   # eg /kata/edit/mzCS1h
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_api()
{
  local -r CONTROLLER=custom
  printf "API /${CONTROLLER}/...\n"
  printf "\t200 GET .../alive? => $(curl_json GET ${CONTROLLER}/alive?)\n"
  printf "\t200 GET .../ready? => $(curl_json GET ${CONTROLLER}/ready?)\n"
  printf "\t200 GET .../sha    => $(curl_json GET ${CONTROLLER}/sha)\n"
  printf '\n'
  printf "\t302 POST HTTP .../create_kata  => $(curl_http_302 POST ${CONTROLLER}/create_kata)\n"
  printf "\t302 POST HTTP .../create_group => $(curl_http_302 POST ${CONTROLLER}/create_group)\n"
  printf '\n'
  printf "\t200 POST JSON .../create_kata  => $(curl_json POST ${CONTROLLER}/create_kata)\n"
  printf "\t200 POST JSON .../create_group => $(curl_json POST ${CONTROLLER}/create_group)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo_deprecated_api()
{
  local -r CONTROLLER=setup_custom_start_point
  printf "Deprecated API (nginx redirect) /${CONTROLLER}/...\n"
  printf "\t302 POST HTTP .../save_individual => $(curl_http_302 POST ${CONTROLLER}/save_individual)\n"
  printf "\t302 POST HTTP .../save_group      => $(curl_http_302 POST ${CONTROLLER}/save_group)\n"
  printf '\n'
  printf "\t200 POST JSON .../save_individual_json => $(curl_json POST ${CONTROLLER}/save_individual_json)\n"
  printf "\t200 POST JSON .../save_group_json      => $(curl_json POST ${CONTROLLER}/save_group_json)\n"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
source ${SH_DIR}/cat_env_vars.sh
export $(cat_env_vars)

${SH_DIR}/build_images.sh
${SH_DIR}/containers_up.sh
printf '\n'
demo_api
printf '\n'
demo_deprecated_api
printf '\n'
${SH_DIR}/containers_down.sh
#open http://${IP_ADDRESS}:$(port)/custom/index

#!/bin/bash -Eeu

readonly SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/sh" && pwd)"
source "${SH_DIR}/build_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/ip_address.sh"

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
api_demo()
{
  build_images
  containers_up api-demo
  echo
  demo
  echo
  if [ "${1:-}" == '--no-browser' ]; then
    containers_down
  else
    open "http://${IP_ADDRESS}:80/custom-chooser/group_choose"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
demo()
{
  echo API
  curl_json_body_200 GET  alive
  curl_json_body_200 GET  ready
  curl_json_body_200 GET  sha
  echo
  curl_200           GET  assets/app.css 'Content-Type: text/css'
  echo
  curl_200           GET  group_choose  exercise
  curl_params_302    GET  group_create "$(params_display_names)"
  echo
  curl_200           GET  kata_choose   exercise
  curl_params_302    GET  kata_create  "$(params_display_name)"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_params_302()
{
  local -r log=/tmp/custom-chooser.log
  local -r type="${1}"     # eg GET|POST
  local -r route="${2}"    # eg kata_create
  local -r params="${3:-}" # eg "display_name=Java Countdown, Round 1"
  curl  \
    --data-urlencode "${params}" \
    --fail \
    --request "${type}" \
    --silent \
    --verbose \
      "http://${IP_ADDRESS}:$(port)/${route}" \
      > "${log}" 2>&1

  grep --quiet 302 "${log}"                 # eg HTTP/1.1 302 Moved Temporarily
  local -r result=$(grep Location "${log}") # Location: http://192.168.99.100:4536/kata/edit/5B65RC
  echo "$(tab)${type} ${route} => 302 ${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_200()
{
  local -r log=/tmp/custom-chooser.log
  local -r type="${1}"    # eg GET|POST
  local -r route="${2}"   # eg kata_choose
  local -r pattern="${3}" # eg session
  curl  \
    --fail \
    --request "${type}" \
    --silent \
    --verbose \
      "http://${IP_ADDRESS}:$(port)/${route}" \
      > "${log}" 2>&1

  grep --quiet 200 "${log}" # eg HTTP/1.1 200 OK
  local -r result=$(grep "${pattern}" "${log}" | head -n 1)
  echo "$(tab)${type} ${route} => 200 ${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { echo -n "${CYBER_DOJO_CUSTOM_CHOOSER_PORT}"; }
json_display_names()   { echo -n "{\"display_names\":[\"$(display_name)\"]}"; }
params_display_names() { params display_names[] "$(display_name)"; }
json_display_name()    { json   display_name "$(display_name)"; }
params_display_name()  { params display_name "$(display_name)"; }
json() { echo -n "{\"${1}\":\"${2}\"}"; }
params() { echo -n "${1}=${2}"; }
display_name() { echo -n 'Java Countdown, Round 1'; }
tab() { printf '\t'; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
api_demo "$@"

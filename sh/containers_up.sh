#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - -
ip_address_slow()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    printf localhost
  fi
}
readonly IP_ADDRESS=$(ip_address_slow)

# - - - - - - - - - - - - - - - - - - - - - -
wait_briefly_until_ready()
{
  local -r port="${1}"
  local -r name="${2}"
  local -r max_tries=20
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries}); do
    if ready ${port}; then
      printf '.OK\n'
      return
    else
      printf .
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  printf "${name} not ready after ${max_tries} tries\n"
  if [ -f "$(ready_response_filename)" ]; then
    printf "$(ready_response)\n"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
ready()
{
  local -r port="${1}"
  local -r path=ready
  local -r ready_cmd="\
    curl \
      --data "{}" \
      --fail \
      --output $(ready_response_filename) \
      --silent \
      -X GET \
        http://${IP_ADDRESS}:${port}/${path}"
  rm -f "$(ready_response_filename)"
  if ${ready_cmd} && [ "$(ready_response)" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - -
ready_response()
{
  cat "$(ready_response_filename)"
}

# - - - - - - - - - - - - - - - - - - -
ready_response_filename()
{
  printf /tmp/curl-custom-ready-output
}

# - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local -r docker_log=$(docker logs "${name}" 2>&1)
  local -r line_count=$(echo -n "${docker_log}" | grep -c '^')
  printf "Checking ${name} started cleanly..."
  # 3 lines on Thin (Unicorn=6, Puma=6)
  #Thin web server (v1.7.2 codename Bachmanity)
  #Maximum connections set to 1024
  #Listening on 0.0.0.0:4536, CTRL+C to stop
  if [ "${line_count}" == '3' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    print_docker_log "${name}" "${docker_log}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
print_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  printf "[docker logs ${name}]\n"
  printf '<docker_log>\n'
  printf "${docker_log}\n"
  printf '</docker_log>\n'
}

# - - - - - - - - - - - - - - - - - - -
container_up()
{
  local -r port="${1}"
  local -r service_name="${2}"
  local -r container_name="test-${service_name}"
  printf '\n'
  export NO_PROMETHEUS=true
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    up \
    --detach \
    --force-recreate \
      "${service_name}"
  if [ "${3:-}" == 'ready' ]; then
    wait_briefly_until_ready "${port}" "${container_name}"
  fi
  #exit_unless_clean "${container_name}"
}

# - - - - - - - - - - - - - - - - - - -

port=${CYBER_DOJO_CUSTOM_PORT}
container_up ${port} custom ready  #[1]

#port=${CYBER_DOJO_CUSTOM_CLIENT_PORT}
#container_up ${port} custom-client

container_up 80 nginx
sleep 1

# [1] can't do clean-check for custom as sinatra-contrib
# does several method redefinitions which cause warnings

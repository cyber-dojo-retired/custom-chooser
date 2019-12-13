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

open "http://$(ip_address):${PORT}/custom/show?from=group"

#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

export $(docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env')

${SH_DIR}/build_docker_images.sh "$@"
${SH_DIR}/docker_containers_up.sh "$@"

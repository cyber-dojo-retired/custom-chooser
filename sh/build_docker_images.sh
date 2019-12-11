#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
export TAG=${SHA:0:7}

build_image()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
      build \
        "${1}"
}

build_image custom
build_image nginx

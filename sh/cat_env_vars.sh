#!/bin/bash
set -e

cat_env_vars()
{
  local -r tag=${CYBER_DOJO_VERSION:-latest}
  docker run --rm cyberdojo/versioner:${tag} sh -c 'cat /app/.env'

  # TODO: these will move into cyberdojo/versioner
  echo CYBER_DOJO_CREATOR_IMAGE=cyberdojo/creator
  echo CYBER_DOJO_CUSTOM_IMAGE=cyberdojo/custom
  echo CYBER_DOJO_CUSTOM_PORT=4536
}

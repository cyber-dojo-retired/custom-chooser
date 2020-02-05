#!/bin/bash -Eeu

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'
  # TODO: these will move into cyberdojo/versioner
  echo CYBER_DOJO_CREATOR_IMAGE=cyberdojo/creator
  echo CYBER_DOJO_CREATOR_PORT=4523  
  echo CYBER_DOJO_CUSTOM_IMAGE=cyberdojo/custom
  echo CYBER_DOJO_CUSTOM_PORT=4536
}

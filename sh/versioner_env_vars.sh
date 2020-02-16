#!/bin/bash -Eeu

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  # TODO: these will move into cyberdojo/versioner
  echo CYBER_DOJO_CUSTOM_CHOOSER_IMAGE=cyberdojo/custom
  echo CYBER_DOJO_CUSTOM_CHOOSER_PORT=4536
}

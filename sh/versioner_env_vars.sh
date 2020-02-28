#!/bin/bash -Eeu

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  # TODO: these will move into cyberdojo/versioner
  echo CYBER_DOJO_CUSTOM_CHOOSER_IMAGE=cyberdojo/custom-chooser
  echo CYBER_DOJO_CUSTOM_CHOOSER_PORT=4536
  echo CYBER_DOJO_CUSTOM_CHOOSER_CLIENT_PORT=4537
}

#!/bin/bash -Eeu

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  echo CYBER_DOJO_CUSTOM_CHOOSER_CLIENT_PORT=4537
}

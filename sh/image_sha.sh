#!/bin/bash -Eeu

image_sha()
{
  docker run --rm ${CYBER_DOJO_CUSTOM_CHOOSER_IMAGE}:latest sh -c 'echo ${SHA}'
}

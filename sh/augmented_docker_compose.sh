#!/bin/bash -Eeu

# cyberdojo/service-yaml image lives at
# https://github.com/cyber-dojo/service-yaml

# Setting --project-name is required to ensure it is
# not custom-chooser (default from the root dir)
# which would be the same as the main docker-compose.yml
# service-name and would prevent .sh scripts which obtain
# the container-name from the service-name from working.
# See sh/container_info.sh

augmented_docker_compose()
{
  cd "${ROOT_DIR}" && cat "./docker-compose.yml" \
    | docker run --rm --interactive cyberdojo/service-yaml \
         custom-start-points \
      exercises-start-points \
      languages-start-points \
                     creator \
                       saver \
    | tee /tmp/augmented-docker-compose.peek.yml \
    | docker-compose \
        --project-name cyber-dojo \
        --file -                  \
        "$@"
}

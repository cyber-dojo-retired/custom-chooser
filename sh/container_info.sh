#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - -
name_port_ls()
{
  docker container ls --format "{{.Names}} {{.Ports}}" --all
}

# - - - - - - - - - - - - - - - - - - -
service_container()
{
  local -r service_name="${1}"
  name_port_ls | grep "${service_name}" | cut -f 1 -d " "
}

: <<'COMMENT'

$ name_port_ls
custom-chooser_custom-chooser-client_1 0.0.0.0:9999->9999/tcp
test-custom-chooser-server 0.0.0.0:4536->4536/tcp
custom-chooser_creator_1 0.0.0.0:4523->4523/tcp
custom-chooser_saver_1 0.0.0.0:4537->4537/tcp
custom-chooser_exercises-start-points_1 0.0.0.0:4525->4525/tcp
custom-chooser_custom-start-points_1 0.0.0.0:4526->4526/tcp
custom-chooser_languages-start-points_1 0.0.0.0:4524->4524/tcp
custom-chooser_selenium_1 0.0.0.0:4444->4444/tcp

1.To get the name of the container running a port 4536
  $ name_port_ls | grep 4536 | cut -f 1 -d " "

2.To get port for container called xxx
  $ name_port_ls | grep xxx | cut -f 2 -d '>' | cut -f 1 -d '/'

3.To get container for a service called xxx
  $ name_port_ls | grep custom-chooser_xxx | cut -f 1 -d " "

4.To get the port for a service called xxx
  $ name_port_ls | grep xxx | cut -f 2 -d '>' | cut -f 1 -d '/'

COMMENT

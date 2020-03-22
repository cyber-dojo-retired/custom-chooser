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

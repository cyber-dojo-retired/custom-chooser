#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${0}")" && pwd)"

export RUBYOPT='-W2'

rackup \
  --env production \
  --host 0.0.0.0   \
  --port ${PORT}   \
  --server thin    \
  --warn           \
    ${MY_DIR}/config.ru

#!/bin/bash -Ee

export RUBYOPT='-W2'

rackup \
  --env production \
  --host 0.0.0.0   \
  --port 4536      \
  --server thin    \
  --warn           \
    config.ru

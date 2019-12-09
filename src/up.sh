#!/bin/bash

export RUBYOPT='-W2'

rackup \
  --env production \
  --port 4536      \
  --warn           \
    config.ru

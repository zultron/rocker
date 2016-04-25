#!/bin/bash

SUITE=$(awk '/^ENV SUITE/ { print $3 }' Dockerfile)
docker build -t dev-${SUITE} "$@" .

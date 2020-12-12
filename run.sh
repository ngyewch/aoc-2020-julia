#!/usr/bin/env bash

JULIA_VERSION=1.5.3

EXAMPLE=$1
INPUT=$2

docker run -it --rm -v "$PWD":/workspace -w /workspace julia:${JULIA_VERSION} julia --project=. day11.jl "${EXAMPLE}" "${INPUT}"

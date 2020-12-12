#!/usr/bin/env bash

EXAMPLE=$1
INPUT=$2

julia --project=. day11.jl "${EXAMPLE}" "${INPUT}"

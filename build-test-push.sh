#!/bin/bash
#
# Shell script that can build this app as a Docker image, run tests on it,
# and if everything passes, push the image to Docker hub.

set -e

readonly DEFAULT_DOCKER_COMMAND="docker"

function build_docker_image {
  local readonly docker_cmd="$1"
  local readonly sha1="$2"

  echo "Building Docker image"
  eval "$docker_cmd build -t brikis98/grails-docker-test:$sha1 ."
}

function run_tests {
  local readonly docker_cmd="$1"
  local readonly sha1="$2"

  echo "Running tests"
  # TODO
}

function push_docker_image {
  local readonly docker_cmd="$1"
  local readonly sha1="$2"

  echo "Pushing Docker image to Docker Hub with tag $sha1"
  eval "$docker_cmd push brikis98/grails-docker-test:$sha1"
}

function parse_command {
  local docker_command="$DEFAULT_DOCKER_COMMAND"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --docker-command)
        docker_command="$2"
        shift
        ;;
      *)
        echo "Unrecognized argument: $key"
        exit 1
        ;;
    esac

    shift
  done

  local readonly sha1=$(git rev-parse --short HEAD)

  build_docker_image "$docker_command" "$sha1"
  run_tests "$docker_command" "$sha1"
  push_docker_image "$docker_command" "$sha1"
}


parse_command "$@"

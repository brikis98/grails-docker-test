#!/bin/bash
#
# Shell script that can build this app as a Docker image, run tests on it,
# and if everything passes, push the image to Docker hub.

set -e

readonly DOCKER_CONFIG_FOLDER=~/.docker
readonly DOCKER_CONFIG_FILE="$DOCKER_CONFIG_FOLDER/config.json"
readonly DEFAULT_DOCKER_COMMAND="docker"

function remove_docker_config_file {
  echo "Removing Docker config file $DOCKER_CONFIG_FILE"
  rm -f "$DOCKER_CONFIG_FILE"
}

function copy_docker_config_file {
  local readonly source_config_file="$1"

  if [[ ! -f "$source_config_file" ]]; then
    echo "ERROR: invalid --docker-config-file parameter specified: $source_config_file"
    exit 1
  fi

  trap remove_docker_config_file EXIT INT TERM
  echo "Copying Docker config file $source_config_file to $DOCKER_CONFIG_FILE"
  mkdir -p "$DOCKER_CONFIG_FOLDER"
  cp "$source_config_file" "$DOCKER_CONFIG_FILE"
}

function build_docker_image {
  local readonly docker_cmd="$1"

  echo "Building Docker image"
  eval "$docker_cmd build -t brikis98/grails-docker-test ."
}

function run_tests {
  local readonly docker_cmd="$1"

  echo "Running tests"
  # TODO
}

function push_docker_image {
  local readonly docker_cmd="$1"

  echo "Pushing Docker image to Docker Hub"
  eval "$docker_cmd push brikis98/grails-docker-test"
  # TODO: tag with build SHA-1
}

function assert_valid_arg {
  local readonly arg="$1"
  local readonly arg_name="$2"

  if [[ -z "$arg" || "${arg:0:1}" = "-" ]]; then
    echo "ERROR: You must provide a value for argument $arg_name"
    exit 1
  fi
}

function parse_command {
  local docker_command="$DEFAULT_DOCKER_COMMAND"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --docker-config-file)
        local readonly docker_config_file="$2"
        copy_docker_config_file "$docker_config_file"
        shift
        ;;
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

  build_docker_image "$docker_command"
  run_tests "$docker_command"
  push_docker_image "$docker_command"
}


parse_command "$@"

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
  if [ "$#" -ne 3 ]; then
    echo "ERROR. You must pass exactly 3 arguments for a custom Docker config.json file: DOCKER_REPO_URL DOCKER_REPO_AUTH DOCKER_REPO_EMAIL."
  fi

  local readonly docker_repo_url="$1"
  local readonly docker_repo_auth="$2"
  local readonly docker_repo_email="$3"

  echo "Creating Docker config file $DOCKER_CONFIG_FILE"
  trap remove_docker_config_file EXIT INT TERM
  mkdir -p "$DOCKER_CONFIG_FOLDER"

  cat << EOF > "$DOCKER_CONFIG_FILE"
{
  "auths": {
    "$docker_repo_url": {
      "auth": "$docker_repo_auth",
      "email": "$docker_repo_email"
    }
  }
EOF
}

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
      --docker-config-file)
        local readonly docker_repo_url="$1"
        local readonly docker_repo_auth="$2"
        local readonly docker_repo_email="$3"
        copy_docker_config_file "$docker_repo_url" "$docker_repo_auth" "$docker_repo_email"
        shift 3
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

  local readonly sha1=$(git rev-parse --short HEAD)

  build_docker_image "$docker_command" "$sha1"
  run_tests "$docker_command" "$sha1"
  push_docker_image "$docker_command" "$sha1"
}


parse_command "$@"

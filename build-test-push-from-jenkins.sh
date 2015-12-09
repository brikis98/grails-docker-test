#!/bin/bash
#
# This script is meant to be run from a Jenkins build. It wraps the
# build-test-push.sh script, configuring parameters the way we need to in
# Jenkins.

set -e

# We run Docker with sudo, so we need the credentials in the root user's HOME
# dir
readonly DOCKER_CONFIG_FOLDER="/root/.docker"
readonly DOCKER_CONFIG_FILE="$DOCKER_CONFIG_FOLDER/config.json"

function remove_docker_config_file {
  echo "Removing Docker config file $DOCKER_CONFIG_FILE"
  sudo rm -f "$DOCKER_CONFIG_FILE"
}

function create_docker_config_file {
  echo "Creating Docker config file $DOCKER_CONFIG_FILE"
  trap remove_docker_config_file EXIT INT TERM
  mkdir -p "$DOCKER_CONFIG_FOLDER"

  # The DOCKER_REPO_XXX params are environment variables that ECS will set in the
  # Jenkins Docker container. They are configured in the Jenkins Terraform
  # templates.
  cat << EOF > "$DOCKER_CONFIG_FILE"
{
  "auths": {
    "$DOCKER_REPO_URL": {
      "auth": "$DOCKER_REPO_AUTH",
      "email": "$DOCKER_REPO_EMAIL"
    }
  }
EOF
}

# The "sudo docker" command is necessary because Jenkins runs in a Docker
# container, so it has to run other Docker containers as "siblings" using
# a mounted Docker socket, and that socket is owned by the root user.
./build-test-push.sh --docker-command "sudo docker"
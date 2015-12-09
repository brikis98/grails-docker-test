#!/bin/bash
#
# This script is meant to be run from a Jenkins build. It wraps the
# build-test-push.sh script, configuring parameters the way we need to in
# Jenkins.

set -e

# The DOCKER_REPO_XXX params are environment variables that ECS will set in the
# Jenkins Docker container. They are configured in the Jenkins Terraform
# templates. The "sudo docker" command is necessary because Jenkins runs in a
# Docker container, so it has to run other Docker containers as "siblings" using
# a mounted Docker socket, and that socket is owned by the root user.
./build-test-push.sh --docker-config-file "$DOCKER_REPO_URL" "$DOCKER_REPO_AUTH" "$DOCKER_REPO_EMAIL" --docker-command "sudo docker"
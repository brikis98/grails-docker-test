#!/bin/bash
#
# Simple script that runs this Grails app in production mode. This is mostly
# to work around the fact that the base Docker image for this Grails app didn't
# set the environment up fully in its own Dockerfile, but instead initializes
# parts of it using a script under //.gvm/bin/gvm-init.sh, which is executed
# by each new command shell.

set -e

bash -l -c "grails prod $@ run-war -restart"

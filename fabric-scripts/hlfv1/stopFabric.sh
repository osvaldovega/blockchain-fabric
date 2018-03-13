#!/bin/bash

# COLORS
RESET='\x1B[0m'
COLOR_BLUE='\x1B[0;34m'
COLOR_BLUE_BOLD='\x1B[1;34m'
COLOR_BLUE_BLINK='\x1B[5;34m'
COLOR_BLUE_UNDERLINE='\x1B[4;34m'
COLOR_GREEN='\x1B[0;32m'
COLOR_GREEN_BOLD='\x1B[1;32m'
COLOR_GREEN_BLINK='\x1B[5;32m'
COLOR_RED='\x1B[0;31m'
COLOR_RED_BOLD='\x1B[1;31m'
COLOR_RED_BLINK='\x1B[5;31m'
COLOR_YELLOW='\x1B[0;33m'
COLOR_YELLOW_BOLD='\x1B[1;33m'
COLOR_YELLOW_BLINK='\x1B[5;33m'



# Exit on first error, print all commands.
set -e

#Detect architecture
ARCH=`uname -m`

# Grab the current directorydirectory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function clearContainers () {
  CONTAINER_IDS=$(docker ps -aq)
  
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo -e "\n$COLOR_YELLOW--- NO CONTAINERS AVAILABLE FOR DELETION --- $RESET \n"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo -e "\n$COLOR_YELLOW--- NO IMAGES AVAILABLE FOR DELETION --- $RESET \n"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

function shutdownDockerContainers() {
  # Shut down the Docker containers that might be currently running.
  cd "${DIR}"/composer
  ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yaml stop
}


shutdownDockerContainers
clearContainers
removeUnwantedImages
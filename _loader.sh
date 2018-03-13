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



echo -e "\n\n\n $COLOR_BLUE_BOLD DEVELOPMENT ONLY SCRIPT FOR HYPERLEDGER FABRIC CONTROL $RESET \n\n\n"


# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THIS_SCRIPT=`basename "$0"`
echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW RUNNING THIS SCRIPT ( '${THIS_SCRIPT}' ) $RESET"

if [ "${HL_FABRIC_VERSION}" ]; then
  export FABRIC_VERSION="${HL_FABRIC_VERSION}"
fi

if [ "${HL_FABRIC_START_TIMEOUT}" ]; then
  export FABRIC_START_TIMEOUT="${HL_FABRIC_START_TIMEOUT}"
fi

if [ -z ${FABRIC_VERSION+x} ]; then
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW FABRIC_VERSION IS UNSET, ASSUMING hlfv1 $RESET"
  export FABRIC_VERSION="hlfv1"
else
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW FABRIC_VERSION IS SET TO '$FABRIC_VERSION' $RESET"
fi


if [ -z ${FABRIC_START_TIMEOUT+x} ]; then
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW FABRIC_START_TIMEOUT IS UNSET, ASSUMING 15 (SECs) $RESET \n"
  export FABRIC_START_TIMEOUT=15
else

   re='^[0-9]+$'
   if ! [[ $FABRIC_START_TIMEOUT =~ $re ]] ; then
      echo "FABRIC_START_TIMEOUT: Not a number" >&2; exit 1
   fi

 echo "FABRIC_START_TIMEOUT is set to '$FABRIC_START_TIMEOUT'"
fi

"${DIR}"/fabric-scripts/"${FABRIC_VERSION}"/"${THIS_SCRIPT}" "$@"

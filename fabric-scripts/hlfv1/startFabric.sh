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

# VARIABLES
ARCH=`uname -m`
CLI_TIMEOUT=10
CLI_DELAY=3
CHANNEL_NAME="composerchannel"
ORDERER_PEER='orderer.example.com:7050'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function stoppingHyperledgerNetwork() {
  
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW STOPPING NETWORK... $RESET \n"

  ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yaml down  

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_GREEN STOPPING NETWORK SUCCESS $RESET \n"
}


function startingHyperledgerNetwork() {

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW STARTING NETWORK... $RESET \n"

  ARCH=$ARCH CHANNEL_NAME=$CHANNEL_NAME TIMEOUT=$CLI_TIMEOUT DELAY=$CLI_DELAY docker-compose -f "${DIR}"/composer/docker-compose.yaml up -d

  if [ $? -ne 0 ]; then
    echo -e "\n$COLOR_RED_BLINK=> STATUS: ERROR - Unable to start network $RESET \n"
    docker logs -f cli
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_GREEN STARTING NETWORK SUCCESS... $RESET \n"
}


function creatingChannel() {

  PEER='peer0.portal.example.com'
  ORDERER_PEER='orderer.example.com:7050'
  CHANNEL_NAME='composerchannel'

  sleep 15


  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW CREATING CHANNEL ON PEER0 ( ${PEER} ), CHANNEL ( ${CHANNEL_NAME} ) $RESET \n"

  docker exec $PEER peer channel create -o $ORDERER_PEER -c $CHANNEL_NAME -f /etc/hyperledger/fabric/configtx/composer-channel.tx #--tls true --cafile $ORDERER_CA

  # sleep ${FABRIC_START_TIMEOUT}

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW CREATING CHANNEL COMPLETE $RESET \n"
}


function joinPeersToChannel() {

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW JOINING PEERS TO CHANNEL ( ${CHANNEL_NAME} ) $RESET \n"
  
  CHANNEL_NAME='composerchannel'
  PEER='peer0.portal.example.com'

  for i in 1;
  do

    sleep 15

    if [ $i == 1 ]; then
      echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW JOINING PEER ( peer0.portal.example.com ) TO CHANNEL ( ${CHANNEL_NAME} ) $RESET \n"
      docker exec -e CORE_PEER_ADDRESS=peer0.portal.example.com:7051 -e CORE_PEER_LOCALMSPID='PortalMSP' -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/users/Admin@portal.example.com/msp $PEER peer channel join -b $CHANNEL_NAME.block
    elif [ $i == 2 ]; then
      echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW JOINING PEER ( peer0.manufacture.example.com ) TO CHANNEL ( ${CHANNEL_NAME} ) $RESET \n"
      docker exec -e CORE_PEER_ADDRESS=peer0.manufacture.example.com:7051 -e CORE_PEER_LOCALMSPID='ManufactureMSP' -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/users/Admin@manufacture.example.com/msp $PEER peer channel join -b $CHANNEL_NAME.block
    elif [ $i == 3 ]; then
      echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW JOINING PEER ( peer0.authority.example.com ) TO CHANNEL ( ${CHANNEL_NAME} ) $RESET \n"
      docker exec -e CORE_PEER_ADDRESS=peer0.authority.example.com:7051 -e CORE_PEER_LOCALMSPID='AuthorityMSP' -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/users/Admin@authority.example.com/msp $PEER peer channel join -b $CHANNEL_NAME.block
    fi

  done

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW JOINING PROCESS COMPLETE $RESET"
}


function updateAnchorPeers() {

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING ANCHOR PEERS $RESET"

  sleep 10

  CONFIGTX='/etc/hyperledger/fabric/configtx'

  PEER='peer0.portal.example.com'
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING ANCHOR PEER ( $PEER ) $RESET \n"
  docker exec $PEER peer channel update -o $ORDERER_PEER -c $CHANNEL_NAME -f $CONFIGTX/PortalMSPanchors.tx

  sleep 5

  PEER='peer0.manufacture.example.com'
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING ANCHOR PEER ( $PEER ) $RESET \n"
  docker exec $PEER peer channel update -o $ORDERER_PEER -c $CHANNEL_NAME -f $CONFIGTX/ManufactureMSPanchors.tx

  sleep 5

  PEER='peer0.authority.example.com'
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING ANCHOR PEER ( $PEER ) $RESET \n"
  docker exec $PEER peer channel update -o $ORDERER_PEER -c $CHANNEL_NAME -f $CONFIGTX/AuthorityMSPanchors.tx

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING ANCHOR PEERs COMPLETE $RESET \n"
}


$DIR/generateCerts.sh
stoppingHyperledgerNetwork
startingHyperledgerNetwork
creatingChannel
updateAnchorPeers
joinPeersToChannel


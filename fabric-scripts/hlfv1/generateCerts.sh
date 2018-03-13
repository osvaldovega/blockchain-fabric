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


# SETTINGS
export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/composer
echo "varas ${FABRIC_CFG_PATH}"
# VARIABLES
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHANNEL_NAME='composerchannel'


# FUNCTIONS
function generateCerts() {

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW CERTIFICATES PROCESS START... $RESET \n"

  which $DIR/bin/cryptogen
  if [ "$?" -ne 0 ]; then
    echo -e "\n $COLOR_BLUE => STATUS: $COLOR_RED_BLINK Cryptogen tool not found. exiting $RESET \n"
    exit 1
  fi

  if [ -d "$DIR/composer/crypto-config" ]; then
    echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW CLEANING CRYPTO-CONFIG FILE $RESET"
    rm -Rf $DIR/composer/crypto-config
  fi
  
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING CERTIFICATES NOW! $RESET \n"
  $DIR/bin/cryptogen generate --config=$DIR/composer/crypto-config.yaml --output=$DIR/composer/crypto-config

  if [ "$?" -ne 0 ]; then
    echo -e "\n $COLOR_BLUE=> STATUS: $COLOR_RED_BLINK FAILED TO GENERATE CERTIFICATES $RESET \n"
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_GREEN_BLINK CERTIFICATE PROCESS COMPLETE $RESET"
}



function generateChannelArtifacts() {
  
  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING ARTIFACTS PROCESS START... $RESET \n"

  which $DIR/bin/configtxgen
  if [ "$?" -ne 0 ]; then
    echo -e "\n $COLOR_BLUE => SATUS: $COLOR_RED_BLINK ( configtxgen ) TOOL NOT FOUND. $RESET \n"
    exit 1
  fi

  if [ -d "$DIR/composer/channel-artifacts" ]; then
    rm -Rf $DIR/composer/channel-artifacts
    mkdir $DIR/composer/channel-artifacts
  else
    mkdir $DIR/composer/channel-artifacts
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING ORDER GENESIS BLOCK $RESET \n"
  $DIR/bin/configtxgen -profile ComposerOrdererGenesis -outputBlock $DIR/composer/channel-artifacts/composer-genesis.block

  if [ "$?" -ne 0 ]; then
    echo -e "\n $COLOR_BLUE=> STATUS: $COLOR_RED_BLINK FAILED TO GENERATE ORDERER GENESIS BLOCK $RESET \n"
    exit 1
  fi


  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING CHANNEL CONFIG TRANSACTION ( channel.tx ) $RESET \n"
  $DIR/bin/configtxgen -profile ComposerChannel -outputCreateChannelTx $DIR/composer/channel-artifacts/composer-channel.tx -channelID $CHANNEL_NAME
  
  if [ "$?" -ne 0 ]; then
    echo -e "\n $COLOR_BLUE => STATUS: $COLOR_RED_BLINK FAILED TO GENERATE CHANNEL CONFIG TRANSACTION $RESET \n"
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING ANCHOR PEER UPDATE FOR PortalMSP $RESET \n"
  $DIR/bin/configtxgen -profile ComposerChannel -outputAnchorPeersUpdate $DIR/composer/channel-artifacts/PortalMSPanchors.tx -channelID $CHANNEL_NAME -asOrg Portal
  
  if [ "$?" -ne 0 ]; then
    echo -e "\n$COLOR_RED_BLINK=> STATUS: FAILED TO GENERATE ANCHOR PEER UPDATE FOR ( PortalMSP ) $RESET \n"
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING ANCHOR PEER UPDATE FOR ManufactureMSP $RESET \n"
  $DIR/bin/configtxgen -profile ComposerChannel -outputAnchorPeersUpdate $DIR/composer/channel-artifacts/ManufactureMSPanchors.tx -channelID $CHANNEL_NAME -asOrg Manufacture
  
  if [ "$?" -ne 0 ]; then
    echo -e "\n$COLOR_RED_BLINK=> STATUS: FAILED TO GENERATE ANCHOR PEER UPDATE FOR ( ManufactureMSP ) $RESET \n"
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW GENERATING ANCHOR PEER UPDATE FOR AuthorityMSP $RESET \n"
  $DIR/bin/configtxgen -profile ComposerChannel -outputAnchorPeersUpdate $DIR/composer/channel-artifacts/AuthorityMSPanchors.tx -channelID $CHANNEL_NAME -asOrg Authority
  
  if [ "$?" -ne 0 ]; then
    echo -e "\n$COLOR_RED_BLINK=> STATUS: FAILED TO GENERATE ANCHOR PEER UPDATE FOR ( AuthorityMSP ) $RESET \n"
    exit 1
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_GREEN_BLINK ARTIFACTS PROCESS COMPLETE $RESET \n"
}



function replacePrivateKeys() {

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW REPLACING PRIVATE KEYS PROCESS START... $RESET \n"

  ARCH=`uname -s | grep Darwin`
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi


  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW COPY LINES FROM TEMPLATE FILE TO EXECUTE FILE $RESET \n"
  cp $DIR/composer/docker-compose-template.yaml $DIR/composer/docker-compose.yaml


  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING KEY FOR PORTAL CA SERVER $RESET \n"
  cd $DIR/composer/crypto-config/peerOrganizations/portal.example.com/ca
  PRIVATE_KEY=$(ls *_sk)
  sed $OPTS "s/CA0_PRIVATE_KEY/${PRIVATE_KEY}/g" $DIR/composer/docker-compose.yaml

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING KEY FOR MANUFACTURE CA SERVER $RESET \n"
  cd $DIR/composer/crypto-config/peerOrganizations/manufacture.example.com/ca
  PRIVATE_KEY=$(ls *_sk)
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIVATE_KEY}/g" $DIR/composer/docker-compose.yaml

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_YELLOW UPDATING KEY FOR AUTHORITY CA SERVER $RESET \n"
  cd $DIR/composer/crypto-config/peerOrganizations/authority.example.com/ca
  PRIVATE_KEY=$(ls *_sk)
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIVATE_KEY}/g" $DIR/composer/docker-compose.yaml

  cd $DIR

  if [ "$ARCH" == "Darwin" ]; then
    rm $DIR/composer/docker-compose.yamlt
  fi

  echo -e "\n $COLOR_BLUE => STATUS: $COLOR_GREEN_BLINK CERTIFICATES REPLACEMENT COMPLETE $RESET \n"
}


# CALLS

generateCerts
generateChannelArtifacts
replacePrivateKeys

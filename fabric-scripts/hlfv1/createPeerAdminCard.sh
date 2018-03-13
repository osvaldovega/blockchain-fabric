#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ORCER_CA="$DIR/composer/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
PEERS_CA="$DIR/composer/crypto-config/peerOrganizations/portal.example.com/peers/peer0.portal.example.com/tls/ca.crt"



function checkComposerVersion() {

    # check that the composer command exists at a version >v0.14
    if hash composer 2>/dev/null; then
        composer --version | awk -F. '{if ($2<15) exit 1}'
        if [ $? -eq 1 ]; then
            echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
            exit 1
        else
            echo Using composer-cli at $(composer --version)
        fi
    else
        echo 'Need to have composer-cli installed at v0.15 or greater'
        exit 1
    fi
}


function createConnectionProfile() {

    cd ${DIR}/composer/crypto-config/peerOrganizations/portal.example.com/users/Admin@portal.example.com/msp/keystore
    PRIVATE_KEY=$(ls *_sk)
    CERT="${DIR}"/composer/crypto-config/peerOrganizations/portal.example.com/users/Admin@portal.example.com/msp/signcerts/Admin@portal.example.com-cert.pem


    if composer card list -n PeerAdmin@hlfv1 > /dev/null; then
        composer card delete -n PeerAdmin@hlfv1
    fi

    composer card create -p /tmp/.connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@hlfv1.card
    
    composer card import --file /tmp/PeerAdmin@hlfv1.card 

    rm -rf /tmp/.connection.json

    echo "Hyperledger Composer PeerAdmin card has been imported"
    composer card list
}


## FUNCTION CALLS
checkComposerVersion

cat << EOF > /tmp/.connection.json
{
    "name": "hlfv1",
    "type": "hlfv1",
    "channel": "composerchannel",
    "mspID": "PortalMSP",
    "timeout": 300,
    "orderers":
    [
        {
           "url": "grpc://localhost:7050"
        }
    ],
    "ca":
    {
        "url": "http://localhost:7054",
        "name": "ca.portal.example.com"
    },
    "peers":
    [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053"
        }
    ]
}
EOF


## FUNCTION CALLS
createConnectionProfile





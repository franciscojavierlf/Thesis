#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build the network (BYFN) WITH end-to-end test"
echo
CHANNEL_NAME_1="$1"
CHANNEL_NAME_2="$2"
DELAY="$3"
LANGUAGE="$4"
TIMEOUT="$5"
VERBOSE="$6"
NO_CHAINCODE="$7"
: ${CHANNEL_NAME_1:="channel1"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="30"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="true"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

CC_SRC_PATH="github.com/hyperledger/fabric-samples/chaincode/abstore/go/"
# /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode
CC_RUNTIME_LANGUAGE=golang

echo
echo "Channel 1 name : "$CHANNEL_NAME_1
echo
echo "Chaincode path : " $CC_SRC_PATH

CHANNEL_NAME=$CHANNEL_NAME_1

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1
			set -x
	peer channel create -o orderer.ecotoken.io:7050 -c $CHANNEL_NAME_1 -f ./channel-artifacts/channel1.tx --tls --cafile $ORDERER_CA >&log.txt
	res=$?
			set +x
	cat log.txt
	verifyResult $res "Channel 1 creation failed"
	echo "===================== Channel '$CHANNEL_NAME_1' created ===================== "
	echo
}

joinChannels() {

	joinChannelWithRetry 0 1 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${1} joined channel '$CHANNEL_NAME' ===================== "
	joinChannelWithRetry 0 2 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${2} joined channel '$CHANNEL_NAME' ===================== "
	joinChannelWithRetry 0 3 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${3} joined channel '$CHANNEL_NAME' ===================== "
}

## Create channels
echo "Creating channels..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannels

## Set the anchor peers for each org in the channels
echo "Updating anchor peers for department1, channel 1..."
updateAnchorPeers 0 1 1
echo
echo "Updating anchor peers for department2, channel 1..."
updateAnchorPeers 0 2 1
echo\
echo "Updating anchor peers for department3, channel 1..."
updateAnchorPeers 0 3 1
echo

echo
echo
echo "=========       Peers are up and ready       =========== "
echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0

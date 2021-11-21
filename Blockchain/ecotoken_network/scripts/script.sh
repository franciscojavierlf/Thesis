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
: ${CHANNEL_NAME_2:="channel2"}
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
echo "Channel 2 name : "$CHANNEL_NAME_2
echo
echo "Chaincode path : " $CC_SRC_PATH

CHANNEL_NAME=$CHANNEL_NAME_1

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1
			set -x
	peer channel create -o orderer.ciencia.edu:7050 -c $CHANNEL_NAME_1 -f ./channel-artifacts/channel1.tx --tls --cafile $ORDERER_CA >&log.txt
	res=$?
			set +x
	cat log.txt
	verifyResult $res "Channel 1 creation failed"
	echo "===================== Channel '$CHANNEL_NAME_1' created ===================== "
	echo
}

createChannel2() {

	setGlobals 0 2
			set -x
	peer channel create -o orderer.ciencia.edu:7050 -c $CHANNEL_NAME_2 -f ./channel-artifacts/channel2.tx --tls --cafile $ORDERER_CA >&log.txt
	res=$?
			set +x
	cat log.txt
	verifyResult $res "Channel 2 creation failed"
	echo "===================== Channel '$CHANNEL_NAME_2' created ===================== "
	echo
}

joinChannels() {

	joinChannelWithRetry 0 1 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${1} joined channel '$CHANNEL_NAME' ===================== "
	joinChannelWithRetry 0 2 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${2} joined channel '$CHANNEL_NAME' ===================== "
	joinChannelWithRetry 0 3 $CHANNEL_NAME_1
	echo "===================== peer${0}.org${3} joined channel '$CHANNEL_NAME' ===================== "

	joinChannelWithRetry 0 2 $CHANNEL_NAME_2
	echo "===================== peer${0}.org${2} joined channel '$CHANNEL_NAME' ===================== "
	joinChannelWithRetry 0 3 $CHANNEL_NAME_2
	echo "===================== peer${0}.org${3} joined channel '$CHANNEL_NAME' ===================== "
	
}

## Create channels
echo "Creating channels..."
createChannel
createChannel2

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
echo "Updating anchor peers for department2, channel 2..."
updateAnchorPeers 0 2 2
echo
echo "Updating anchor peers for department3, channel 2..."
updateAnchorPeers 0 3 2
echo


#############################################################################################
#############################################################################################
#############################################################################################
#############################################################################################
########################instalaChaincode.sh
########################
#############################################################################################
#############################################################################################
# ##############################################################

## at first we package the chaincode
echo "Packaging the chaincode..."
packageChaincode 1 0 1

echo "Installing chaincode on author0.department1..."
installChaincode 0 1

echo "Installing chaincode on author0.department3..."
installChaincode 0 3

## query whether the chaincode is installed
queryInstalled 0 1

## approve the definition for org1
approveForMyOrg 1 0 1
## now approve also for org3
approveForMyOrg 1 0 3

## check whether the chaincode definition is ready to be committed
checkCommitReadiness 1 0 3 "\"Org3MSP\": true"

## now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition 1 0 1 0 3

## query on both orgs to see that the definition committed successfully
queryCommitted 1 0 1
queryCommitted 1 0 3

# invoke init
chaincodeInvoke 1 0 1 0 3

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0...."
chaincodeQuery 0 1 100


#############################################################################################
#############################################################################################
#############################################################################################
#############################################################################################
########################pruebaChaincode.sh
########################
#############################################################################################
#############################################################################################
# ##############################################################

# Invoke chaincode on peer0.org1 and peer0.org3
echo "Sending invoke transaction on author0.department1 author0.department3..."
chaincodeInvoke 0 0 1 0 3

# Query chaincode on peer0.org1
echo "Querying chaincode on author0.department1..."
chaincodeQuery 0 1 90

# Query chaincode on peer0.org3
echo "Querying chaincode on author0.department3..."
chaincodeQuery 0 3 90

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

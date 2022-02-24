#!/bin/bash
#
# Project title: Red Prueba
# File name: byfn.sh
# File creation date: February 27, 2021
# Last modification date: February 27, 2021
# Modification done by: AFMH

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false
#xport IMAGE_TAG="latest"
export SYS_CHANNEL="byfn-sys-channel"

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  byfn.sh <mode> [-b <channel name 2>] [-c <channel name 2>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-i <imagetag>] [-a] [-n] [-v]"
  echo "    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "    -b <channel name 2> - channel name to use for channel 2 (defaults to \"channel_2\")"  
  echo "    -c <channel name 2> - channel name to use for channel 2 (defaults to \"channel_2\")"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
  echo "    -a - launch certificate authorities (no certificate authorities are launched by default)"
  echo "    -n - do not deploy chaincode (abstore chaincode is deployed by default)"
  echo "    -v - verbose mode"
  echo "  byfn.sh -h (print this message)"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	byfn.sh generate -b channel_1 -c channel_2"
  echo "        byfn.sh up -b channel_1 -c channel_2 -i 1.4.0"
  echo "	byfn.sh down -b channel_1 -c channel_2"
  echo
  echo "Taking all defaults:"
  echo "	byfn.sh generate"
  echo "	byfn.sh up"
  echo "	byfn.sh down"
  echo "	byfn.sh restart"
}

# Ask user for confirmation to proceed
function askProceed() {
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
	echo "invalid response"
	askProceed
    ;;
  esac
}

# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# TODO list generated image naming patterns
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

####################################################### Begining of functions
# Versions of fabric known not to work with this release of first-network
BLACKLISTED_VERSIONS="^1\.0\. ^1\.1\.0-preview ^1\.1\.0-alpha"

# Do some basic sanity checking to make sure that the appropriate versions of fabric
# binaries/images are available.  In the future, additional checking for the presence
# of go or other items could be added.
function checkPrereqs() {
  # Note, we check configtxlator externally because it does not require a config file, and peer in the
  # docker image because of FAB-8551 that makes configtxlator return 'development version' in docker
  LOCAL_VERSION=$(configtxlator version | sed -ne 's/ Version: //p')
  DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:$IMAGETAG peer version | sed -ne 's/ Version: //p' | head -1)

  echo "LOCAL_VERSION=$LOCAL_VERSION"
  echo "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

  if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
    echo "=================== WARNING ==================="
    echo "  Local fabric binaries and docker images are  "
    echo "  out of  sync. This may cause problems.       "
    echo "==============================================="
  fi

  for UNSUPPORTED_VERSION in $BLACKLISTED_VERSIONS; do
    echo "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Local Fabric binary version of $LOCAL_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi

    echo "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Fabric Docker image version of $DOCKER_IMAGE_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi
  done
}

function networkUp() {
  
  checkPrereqs
  # Start the Network
  # generate artifacts if they don't exist
  if [ ! -d "crypto-config" ]; then
    generateCerts
    replacePrivateKey
    generateChannelArtifacts
  fi
  
  COMPOSE_FILES="-f ${COMPOSE_FILE}"
  if [ "${CERTIFICATE_AUTHORITIES}" == "true" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_CA}" #peer0.org1.risks.org #author1.department1.university1.org
    export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/department1.university1.edu/ca && ls *_sk)
    export BYFN_CA2_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/department2.university2.edu/ca && ls *_sk)
    export BYFN_CA3_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/department3.university3.edu/ca && ls *_sk)
  fi
  COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
  echo "#################################################################"
  echo "######                    Starting Network                 ######"
  echo "#################################################################"
  echo "$COMPOSE_FILES"
  # Start the Network
  IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} up -d 2>&1	
  docker ps -a
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    exit 1
  fi

  sleep 1
  echo "Sleeping 15s to allow SOLO/Raft? cluster to complete booting"
  sleep 15

  # NEW For v2.0
  echo "Valor de NO_CHAINCODE ... "
  echo $NO_CHAINCODE
  
  # Getting dependencies for Chaincode 
  # Careful with location ... needs to be updated
  if [ "${NO_CHAINCODE}" != "true" ]; then
    echo Vendoring Go dependencies ...
    pushd ../chaincode/abstore/go
    #GO111MODULE=on 
    go mod vendor
    popd
    echo Finished vendoring Go dependencies
  fi  

  # now run the end to end script
  docker exec cli scripts/script.sh $CHANNEL_NAME_1 $CHANNEL_NAME_2 $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE $NO_CHAINCODE
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Test failed"
    exit 1
  fi
}

# Tear down running network
function networkDown() {
  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH  -f $COMPOSE_FILE_CA down --volumes --remove-orphans

  # Don't remove the generated artifacts -- note, the ledgers are always removed
  if [ "$MODE" != "restart" ]; then
    # Bring down the network, deleting the volumes
    #Delete any ledger backups
    docker run -v $PWD:/tmp/my-network --rm hyperledger/fabric-tools:$IMAGETAG rm -Rf /tmp/my-network/ledgers-backup
    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
	# remove orderer block and other channel configuration transactions and certs
	rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
	# remove the docker-compose yaml file that was customized to the example
    rm -f docker-compose-e2e.yaml
  fi
}

# Using docker-compose-e2e-template.yaml, replace constants with private key file names
# generated by the cryptogen tool and output a docker-compose.yaml specific to this
# configuration
function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp docker-compose-e2e-template.yaml docker-compose-e2e.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the CAs.
  CURRENT_DIR=$PWD
  cd crypto-config/peerOrganizations/department1.university1.edu/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  
  cd crypto-config/peerOrganizations/department2.university2.edu/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  
  cd crypto-config/peerOrganizations/department3.university3.edu/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-e2e.yaml
  
  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose-e2e.yamlt
  fi
}

# Generates Org certs using cryptogen tool
function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"
  
  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo

  echo "Generate CCP files for department1, department2, department3"
  ./ccp-generate.sh

}

# Generate orderer genesis block, channel configuration transaction and
# anchor peer update transactions
function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  configtxgen -profile RedPruebaOrdererGenesis -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block
  res=$?
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "##################################################################"
  echo "### Generating channel configuration transaction 'channel1.tx' ###"
  echo "##################################################################"
  set -x
  configtxgen -profile RedPruebaChannel1 -outputCreateChannelTx ./channel-artifacts/channel1.tx -channelID $CHANNEL_NAME_1
  res=$?
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel 1 configuration transaction..."
    exit 1
  fi
  
  echo
  echo "##################################################################"
  echo "### Generating channel configuration transaction 'channel2.tx' ###"
  echo "##################################################################"
  set -x
  configtxgen -profile RedPruebaChannel2 -outputCreateChannelTx ./channel-artifacts/channel2.tx -channelID $CHANNEL_NAME_2
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel 2 configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "############## Generate Anchor Peers for Channel 1 ##############"
  echo "#################################################################"

  echo
  echo "#################################################################"
  echo "####   Generating anchor peer update for department1MSP - university1  ##"
  echo "#################################################################"
  set -x
  configtxgen -profile RedPruebaChannel1 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME_1 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for department1MSP in $CHANNEL_NAME_1"
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "####   Generating anchor peer update for department1MSP - university2  ##"
  echo "#################################################################"
  set -x
  configtxgen -profile RedPruebaChannel1 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME_1 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for department2MSP in $CHANNEL_NAME_1"
    exit 1
  fi
    
  echo
  echo "#################################################################"
  echo "###  Generating anchor peer update for department3MSP - university2  ####"
  echo "#################################################################"
  set -x
  configtxgen -profile RedPruebaChannel1 -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME_1 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for department3MSP in $CHANNEL_NAME_1"
    exit 1
  fi
  
  echo "#################################################################"
  echo "############## Generate Anchor Peers for Channel 2 ##############"
  echo "#################################################################"
  echo
   
  echo
  echo "#################################################################"
  echo "### Generating anchor peer update for department2MSP - university2 ###"
  echo "#################################################################"
  set -x
  configtxgen -profile RedPruebaChannel2 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_${CHANNEL_NAME_2}.tx -channelID $CHANNEL_NAME_2 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for department2MSP  in $CHANNEL_NAME_2"
    exit 1
  fi
  
    echo
  echo "#################################################################"
  echo "###  Generating anchor peer update for department3MSP - university3  ####"
  echo "#################################################################"
  set -x
  configtxgen -profile RedPruebaChannel2 -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors_${CHANNEL_NAME_2}.tx -channelID $CHANNEL_NAME_2 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for department3MSP in $CHANNEL_NAME_2"
    exit 1
  fi
  
  echo
  echo
}

####################################################### End of functions
# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=20
# default for delay between commands
CLI_DELAY=4
# channel name defaults to "channel1" and "channel2"
CHANNEL_NAME_1="channel1"
CHANNEL_NAME_2="channel2"
# use this as the default docker-compose yaml definition
COMPOSE_FILE=docker-compose-cli.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker-compose-ca.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# use golang as the default language for chaincode
LANGUAGE=golang
# default image tag
IMAGETAG="latest"
# default consensus type
CONSENSUS_TYPE="solo"
# default Couch Data Base
IF_COUCHDB="couchdb"
# Certificate Authorities
CERTIFICATE_AUTHORITIES="true"
# No chaincode as default
NO_CHAINCODE="false"
# Verbose mode
VERBOSE="true"
# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, or generating
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
elif [ "$MODE" == "restart" ]; then
  EXPMODE="Restarting"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis block"
else
  printHelp
  exit 1
fi

while getopts "h?c:t:d:f:s:l:i:o:anv" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  b)
    CHANNEL_NAME_1=$OPTARG
    ;;
  c)
    CHANNEL_NAME_2=$OPTARG
    ;;
  t)
    CLI_TIMEOUT=$OPTARG
    ;;
  d)
    CLI_DELAY=$OPTARG
    ;;
  f)
    COMPOSE_FILE=$OPTARG
    ;;
  i)
    IMAGETAG=$(go env GOARCH)"-"$OPTARG
    ;;
  a)
    CERTIFICATE_AUTHORITIES=$OPTARG
    ;;
  n)
    NO_CHAINCODE=$OPTARG
    ;;
  v)
    VERBOSE=$OPTARG
    ;;
  esac
done

# Announce what was requested

echo
echo "${EXPMODE} for channels '${CHANNEL_NAME_1}'  and '${CHANNEL_NAME_2}' with CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${IF_COUCHDB}'"

# ask for confirmation to proceed
askProceed

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
  replacePrivateKey
  generateChannelArtifacts
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
else
  printHelp
  exit 1
fi

######### Preparación
# Hacer copia de carpeta chaincode/ecotoken/go
# Eliminar ecotoken 
# Eliminar .sum
docker volume prune

# Para entrar al cli
docker exec -it cli /bin/bash

# Preparar variables necesarias
export CHANNEL_NAME=channel1
export CHAINCODE_NAME=ecotoken
export CHAINCODE_VERSION=1
export CC_RUNTIME_LANGUAGE=golang
export CC_SRC_PATH="../../fabric-samples/chaincode/$CHAINCODE_NAME/go"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ecotoken.io/orderers/orderer.ecotoken.io/msp/tlscacerts/tlsca.ecotoken.io-cert.pem

######### Paso 1 - Empaquetar el chaincode
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} > log.txt

######### Paso 2 - Instalar en los peers que quiera
### Instalar en el peer0 de la primera organizaciòn
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

# Consultar si se instalo correctamente
peer lifecycle chaincode queryinstalled

# Installed chaincodes on peer:
# Package ID: mycc_1:87657bee804570d2050ea11897c915a8f4e58b55b44b581d70593542b4082c8b, Label: mycc_1
# Package ID: ecotoken_1:632304e08c405194067d340681c0883304242271f6346c8cefe6de35c8f8cfc9, Label: ecotoken_1
# Cambiar ID por el generado a cada uno

export CC_PACKAGEID=686e9f43e1a2136cab2494ebae0034bed1734cfc0c2818dfe1d73f44e5219df8

# Peer 0 Org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ngo1.org/users/Admin@ngo1.org/msp/
CORE_PEER_ADDRESS=peer0.ngo1.org:6051 
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ngo1.org/peers/peer0.ngo1.org/tls/ca.crt 
peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz

peer lifecycle chaincode queryinstalled

# Peer 0 Org3
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/startup1.com/users/Admin@startup1.com/msp/
CORE_PEER_ADDRESS=peer0.startup1.com:7051 
CORE_PEER_LOCALMSPID="Org3MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/startup1.com/peers/peer0.startup1.com/tls/ca.crt
peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz

peer lifecycle chaincode queryinstalled

######### Paso 3 - Aprobar para las organizaciones

### Aprobar para Org 3
peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id ecotoken_1:$CC_PACKAGEID

peer lifecycle chaincode queryapproved --channelID channel1 --name ecotoken

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --output json

### Aprobar para Org 1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/government1.gov/users/Admin@government1.gov/msp/
CORE_PEER_ADDRESS=peer0.government1.gov:5051 
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/government1.gov/peers/peer0.government1.gov/tls/ca.crt

peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id ecotoken_1:$CC_PACKAGEID

peer lifecycle chaincode queryapproved --channelID channel1 --name ecotoken

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --output json

######### Paso 4 - Commit 
# Una vez que se cumpla la politica de quienes han aprobado el chaincode, un peer puede hacer commit del chaincode
# Ver querycommitted para mycc
# peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ecotoken --output json

peer lifecycle chaincode commit -o orderer.ecotoken.io:7050 --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --peerAddresses peer0.government1.gov:5051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.startup1.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/startup1.com/peers/peer0.startup1.com/tls/ca.crt --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')"

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ecotoken --output json

############## FIN


# Para entrar al contrato
peer chaincode invoke -C channel1 -n ecotoken -c '{"Args": ["InitLedger"]}' -o orderer.ecotoken.io:7050 --tls --cafile $ORDERER_CA

peer chaincode query -C channel1 -n ecotoken -c '{"Args":["QueryAllWallets"]}' 

#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $6)
    local CP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${NAME}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${P1PORT}/$4/" \
        -e "s/\${CAPORT}/$5/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json 
}

ORG=1
NAME="government1"
P0PORT=5051
P1PORT=5056
CAPORT=5054
PEERPEM='crypto-config/peerOrganizations/government1.gov/peers/peer0.government1.gov/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/government1.gov/ca/ca.government1.gov-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org1.json

ORG=2
NAME="ngo1"
P0PORT=6051
P1PORT=6056
CAPORT=6054
PEERPEM='crypto-config/peerOrganizations/ngo1.org/peers/peer0.ngo1.org/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/ngo1.org/ca/ca.ngo1.org-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org2.json

ORG=3
NAME="startup1"
P0PORT=7051
P1PORT=7056
CAPORT=7054
PEERPEM='crypto-config/peerOrganizations/startup1.com/peers/peer0.startup1.com/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/startup1.com/ca/ca.startup1.com-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org3.json

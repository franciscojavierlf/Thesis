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
NAME="university1"
P0PORT=5051
P1PORT=5056
CAPORT=5054
PEERPEM='crypto-config/peerOrganizations/department1.university1.edu/peers/peer0.department1.university1.edu/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/department1.university1.edu/ca/ca.department1.university1.edu-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org1.json

ORG=2
NAME="university2"
P0PORT=6051
P1PORT=6056
CAPORT=6054
PEERPEM='crypto-config/peerOrganizations/department2.university2.edu/peers/peer0.department2.university2.edu/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/department2.university2.edu/ca/ca.department2.university2.edu-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org2.json

ORG=3
NAME="university3"
P0PORT=7051
P1PORT=7056
CAPORT=7054
PEERPEM='crypto-config/peerOrganizations/department3.university3.edu/peers/peer0.department3.university3.edu/tls/ca.crt'
CAPEM=crypto-config/peerOrganizations/department3.university3.edu/ca/ca.department3.university3.edu-cert.pem

echo "$(json_ccp $ORG $NAME $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > connection-org3.json

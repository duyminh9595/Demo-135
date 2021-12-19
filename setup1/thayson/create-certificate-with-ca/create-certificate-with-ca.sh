createcertificatesForOrg1() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/

  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.org1.thesis.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.org1.thesis.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  fabric-ca-client register --caname ca.org1.thesis.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.org1.thesis.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.org1.thesis.com --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/msp --csr.hosts peer0.org1.thesis.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls --enrollment.profile tls --csr.hosts peer0.org1.thesis.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/tlsca/tlsca.org1.thesis.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer0.org1.thesis.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/ca/ca.org1.thesis.com-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com

  echo
  echo "## Generate the peer1 msp"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/msp --csr.hosts peer1.org1.thesis.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls --enrollment.profile tls --csr.hosts peer1.org1.thesis.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/peers/peer1.org1.thesis.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/users
  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/users/User1@org1.thesis.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/users/User1@org1.thesis.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/org1.thesis.com/users/Admin@org1.thesis.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca.org1.thesis.com -M ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/users/Admin@org1.thesis.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org1.thesis.com/users/Admin@org1.thesis.com/msp/config.yaml

}

createcertificatesForOrg1

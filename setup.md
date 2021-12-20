# first setup
docker swarm leave --force
docker rm -vf $(docker ps -aq) && docker volume prune -f
docker network prune

# docker swarm
cohuong 104.197.116.180
thayson orderer 34.71.102.58
docker swarm init --advertise-addr 34.71.102.58
docker swarm join --token SWMTKN-1-0lnxed7tro9a8yyqejh8dkuoolsnw6kv0qskxvna67ia1u521x-e01tfxtaq6kvevl1ymk1rg62f 34.71.102.58:2377 --advertise-addr 104.197.116.180
docker network create --attachable --driver overlay artifacts_thesis

# remove ca
rm -r -f ../thayson/crypto-config/
rm -r -f ../thayson/create-certificate-with-ca/fabric-ca/
rm -r -f ../cohuong/crypto-config/
rm -r -f ../cohuong/create-certificate-with-ca/fabric-ca/
rm -r -f ../orderer/crypto-config/
rm -r -f ../orderer/create-certificate-with-ca/fabric-ca/

# tạo ca
cd thayson/create-certificate-with-ca/
docker-compose up -d
./create-certificate-with-ca.sh 
cd ../../cohuong/create-certificate-with-ca/
docker-compose up -d
./create-certificate-with-ca.sh 
cd ../../orderer/create-certificate-with-ca/
docker-compose up -d
./create-certificate-with-ca.sh 
cd ../../../artifacts/channel/
./create-artifacts.sh 

cd /home/ubuntu/Demo-135/setup1/thayson
docker-compose up -d
cd /home/ubuntu/Demo-135/setup1/orderer
docker-compose up -d
cd /home/ubuntu/Demo-135/setup1/cohuong
docker-compose up -d


# add extra hosts
extra_hosts:
      - "orderer.thesis.com:34.71.102.58"
      - "orderer2.thesis.com:34.71.102.58"
      - "orderer3.thesis.com:34.71.102.58"
      - "peer0.thayson.thesis.com:34.71.102.58"
      - "peer1.thayson.thesis.com:34.71.102.58"
      - "peer0.cohuong.thesis.com:104.197.116.180"
      - "peer1.cohuong.thesis.com:104.197.116.180"


# code in cli
docker exec -it cli bash

export CORE_PEER_LOCALMSPID="thaysonMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/channel/crypto-config/peerOrganizations/thayson.thesis.com/peers/peer0.thayson.thesis.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/thayson.thesis.com/users/Admin@thayson.thesis.com/msp
export CORE_PEER_ADDRESS=peer0.thayson.thesis.com:7051
export CHANNEL_NAME="mychannel"
export CC_NAME="fabcar"
export ORDERER_CA=/etc/hyperledger/channel/crypto-config/ordererOrganizations/thesis.com/orderers/orderer.thesis.com/msp/tlscacerts/tlsca.thesis.com-cert.pem
export VERSION="1"

peer lifecycle chaincode commit -o orderer.thesis.com:7050 --ordererTLSHostnameOverride orderer.thesis.com \
--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
--channelID $CHANNEL_NAME --name ${CC_NAME} \
--peerAddresses peer0.thayson.thesis.com:7051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/thayson.thesis.com/peers/peer0.thayson.thesis.com/tls/ca.crt \
--peerAddresses peer0.cohuong.thesis.com:9051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/cohuong.thesis.com/peers/peer0.cohuong.thesis.com/tls/ca.crt \
--version ${VERSION} --sequence ${VERSION} --init-required


peer chaincode invoke -o orderer.thesis.com:7050 \
--ordererTLSHostnameOverride orderer.thesis.com \
--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
-C $CHANNEL_NAME -n ${CC_NAME} \
--peerAddresses peer0.thayson.thesis.com:7051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/thayson.thesis.com/peers/peer0.thayson.thesis.com/tls/ca.crt \
--peerAddresses peer0.cohuong.thesis.com:9051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/cohuong.thesis.com/peers/peer0.cohuong.thesis.com/tls/ca.crt \
--isInit -c '{"Args":[]}' 

peer chaincode invoke -o orderer.thesis.com:7050 \
--ordererTLSHostnameOverride orderer.thesis.com \
--tls \
--cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/thesis.com/orderers/orderer.thesis.com/msp/tlscacerts/tlsca.thesis.com-cert.pem \
-C mychannel -n fabcar \
--peerAddresses peer0.thayson.thesis.com:7051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/thayson.thesis.com/peers/peer0.thayson.thesis.com/tls/ca.crt \
--peerAddresses peer0.cohuong.thesis.com:9051 --tlsRootCertFiles /etc/hyperledger/channel/crypto-config/peerOrganizations/cohuong.thesis.com/peers/peer0.cohuong.thesis.com/tls/ca.crt \
-c '{"function": "createCar","Args":["666666", "Audi", "R8", "Red", "Sandip"]}'
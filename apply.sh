#!/bin/bash

source /.env

nodeContainerId=`docker ps -qf name=tomochain`
chainBlockNumber=`docker exec ${nodeContainerId} tomo attach https://testnet.tomochain.com --exec 'eth.blockNumber'`
nodeBlockNumber=`docker exec ${nodeContainerId} tomo attach data/tomo.ipc --exec 'eth.blockNumber'`
echo $chainBlockNumber
echo $nodeBlockNumber
 
if [ "${chainBlockNumber}" == "${nodeBlockNumber}" ]; then
	# appy to become a candidate
	url --header "Content-Type: application/json" \
	  --request POST \
	  "https://master.testnet.tomochain.com/api/candidates/apply?key=${OWNER_PRIVATE_KEY}&coinbase=${COINBASE_ADDRESS}"
fi

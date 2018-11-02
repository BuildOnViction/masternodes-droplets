#!/bin/bash

source /.env

nodeContainerId=`docker ps -qf name=tomochain`
chainBlockNumber=`docker exec ${nodeContainerId} tomo attach "${RPC_URL}" --exec 'eth.blockNumber'`
nodeBlockNumber=`docker exec ${nodeContainerId} tomo attach data/tomo.ipc --exec 'eth.blockNumber'`
echo $chainBlockNumber
echo $nodeBlockNumber
 
if [ "${chainBlockNumber}" == "${nodeBlockNumber}" ]; then
    # store the whole response with the status at the and
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET ${TOMOMASTER}/api/candidates/${COINBASE_ADDRESS}/isCandidate)

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')


    if [ "${HTTP_BODY}" != "1" ]; then
        curl --header "Content-Type: application/json" \
          --request POST \
          "${TOMOMASTER}/api/candidates/apply?key=${OWNER_PRIVATE_KEY}&coinbase=${COINBASE_ADDRESS}"
    fi
fi

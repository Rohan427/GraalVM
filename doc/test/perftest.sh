#!/bin/bash

COUNT=1
INDEX=0
ITERATION=1
IMAGEPREFIX="perftest"
VERSION="1.2"
FULLJVM="jvmfull"
TINYJVM="tinyjvm"
FULLNATIVE="fullnative"
TINYNATIVE="tinynative"
NEWMANPATH="newman/"
CLEAN="true"
DOCKERPS=$(docker ps -a)

if [[ $# -ne 0 ]];
then
    COUNT=$1
    ITERATION=$2

    if [[ -z "$3" ]];
    then
        echo "Clean Enabled"
    else
        CLEAN=$3
    fi
fi

echo "${DOCKERPS}"



# Create and Start the containers
if  [[ $DOCKERPS != *"${FULLJVM}"* ]];
then
    docker run -d -p 0.0.0.0:8000:8000 --name ${FULLJVM} ${IMAGEPREFIX}-${FULLJVM}:${VERSION}
fi

if  [[ $DOCKERPS != *"${TINYJVM}"* ]];
then
    docker run -d -p 0.0.0.0:8001:8000 --name ${TINYJVM} ${IMAGEPREFIX}/${TINYJVM}:${VERSION}
fi

if  [[ $DOCKERPS != *"${FULLNATIVE}"* ]];
then
    docker run -d -p 0.0.0.0:8002:8000 --name ${FULLNATIVE} ${IMAGEPREFIX}/${FULLNATIVE}:${VERSION}
fi

if  [[ $DOCKERPS != *"${TINYNATIVE}"* ]];
then
    docker run -d -p 0.0.0.0:8003:8000 --name ${TINYNATIVE} ${IMAGEPREFIX}/${TINYNATIVE}:${VERSION}
fi

# Stop the containers
docker stop ${FULLJVM}
docker stop ${TINYJVM}
docker stop ${FULLNATIVE}
docker stop ${TINYNATIVE}

# Run through the containers $COUNT number of times and test each one $ITERATION times.
# Record the results for each intrun eration as $[container_name]$COUNT.html
for (( INDEX=1; INDEX<=$COUNT; INDEX++ ))
do
    echo "+++++++++ Run ${INDEX} ++++++++"

    docker start ${FULLJVM}
    sleep 7
    newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Full_JVM.postman_environment.json -n ${ITERATION} -r cli,htmlextra --reporter-htmlextra-browserTitle "${FULLJVM} ${INDEX} Report" --reporter-htmlextra-title "${FULLJVM} Run ${INDEX}"  --reporter-htmlextra-export ${NEWMANPATH}/${FULLJVM}${INDEX}.html
    docker stop ${FULLJVM}

    docker start ${TINYJVM}
    sleep 5
    newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Tiny_JVM.postman_environment.json -n ${ITERATION} -r cli,htmlextra --reporter-htmlextra-browserTitle "${TINYJVM} ${INDEX} Report" --reporter-htmlextra-title "${TINYJVM} Run ${INDEX}" --reporter-htmlextra-export ${NEWMANPATH}/${TINYJVM}${INDEX}.html
    docker stop ${TINYJVM}

    docker start ${FULLNATIVE}
     sleep 5
    newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Full_GraalVM.postman_environment.json -n ${ITERATION} -r cli,htmlextra --reporter-htmlextra-browserTitle "${FULLNATIVE} ${INDEX} Report" --reporter-htmlextra-title "${FULLNATIVE} Run ${INDEX}" --reporter-htmlextra-export ${NEWMANPATH}/${FULLNATIVE}${INDEX}.html
    docker stop ${FULLNATIVE}

    docker start ${TINYNATIVE}
     sleep 5
    newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Tiny_GraalVM.postman_environment.json -n ${ITERATION} -r cli,htmlextra --reporter-htmlextra-browserTitle "${TINYNATIVE} ${INDEX} Report" --reporter-htmlextra-title "${TINYNATIVE} Run ${INDEX}" --reporter-htmlextra-export ${NEWMANPATH}/${TINYNATIVE}${INDEX}.html
    docker stop ${TINYNATIVE}

    echo "+++++++ Run ${INDEX} END +++++++"

done

if [[ $CLEAN == "true" ]];
then
    docker rm ${FULLJVM}
    docker rm ${TINYJVM}
    docker rm ${FULLNATIVE}
    docker rm ${TINYNATIVE}
fi


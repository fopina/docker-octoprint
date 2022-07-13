#!/bin/bash

if [ -z "$1" ]; then
    echo missing image name
    exit 1
fi

set -e

CONT=$(docker run -d --rm -p5000:5000 $1)

trap cleanup INT QUIT EXIT

function cleanup() {
    echo removing container
    docker rm -f $CONT
}

for i in $(seq 10); do
    OUT=$(curl -s localhost:5000/api/version || true)
    echo Attempt $i
    if [[ "$OUT" == *"the permission to access"* ]]; then
        echo WORKING
        exit 0
    fi
    sleep 0.5
done

echo FAILED
exit 1

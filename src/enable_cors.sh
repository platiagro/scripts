#!/bin/bash

enable_cors="$1"

if [ "$enable_cors" = "" ]; then
    read -p "Do you want to ENABLE or DISABLE CORS errors? (1 = DISABLE / 0 = ENABLE): " enable_cors
fi

if [ "$enable_cors" = "" ]; then
    echo 'Missing $enable_cors'
    exit 0
elif [ "$enable_cors" != "1" -a "$enable_cors" != "0" ]; then
    echo 'The $enable_cors variable can only be 1 or 0'
    exit 0
fi

kubectl get deployments -A | awk -v enable_cors="$enable_cors" '{if (NR!=1) {print " -n " $1 " set env deployment/" $2 " ENABLE_CORS=" enable_cors}}' | xargs -L 1 kubectl

#!/bin/bash

read -p "Should enable or disable CORS (1 to enable, 0 to disable): " should_enable

if [ "$should_enable" = "" ]; then
    echo 'missing $should_enable'
    exit 0
elif [ "$should_enable" != "0" -a "$should_enable" != "1" ]; then
    echo '$should_enable must be 0 or 1'
    exit 0
fi

kubectl get deployments -A | awk -v should_enable="$should_enable" '{if (NR!=1) {print " -n " $1 " set env deployment/" $2 " ENABLE_CORS=" should_enable}}' | xargs -L 1 kubectl

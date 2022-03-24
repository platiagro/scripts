#!/bin/bash

pod="$1"
tag="$2"

if [ "$pod" = "" ]; then
    read -p "Pod (Ex: web-ui): " pod
fi

if [ "$tag" = "" ]; then
    read -p "Tag (Ex: DEVELOP): " tag
fi

if [ "$pod" = "" ]; then
    echo 'Missing $pod'
    exit 0
fi

if [ "$tag" = "" ]; then
    echo 'Missing $tag'
    exit 0
fi

sudo docker pull platiagro/$pod:$tag
kubectl -n platiagro set image deployment/$pod $pod=docker.io/platiagro/$pod:$tag

#!/bin/bash

MINIO=$(kubectl -n platiagro get pod -l app=minio -o jsonpath={.items..metadata.name})

until kubectl -n platiagro port-forward $MINIO 32001:9000 --address 0.0.0.0; do
    echo "kubectl port-forward crashed with exit code $?.  Respawning.." >&2
    sleep 1
    MINIO=$(kubectl -n platiagro get pod -l app=minio -o jsonpath={.items..metadata.name})
done
#!/bin/bash

MYSQL=$(kubectl -n platiagro get pod -l app=mysql -o jsonpath={.items..metadata.name})

until kubectl -n platiagro port-forward $MYSQL 31001:3306 --address 0.0.0.0; do
    echo "kubectl port-forward crashed with exit code $?.  Respawning.." >&2
    sleep 1
    MYSQL=$(kubectl -n platiagro get pod -l app=mysql -o jsonpath={.items..metadata.name})

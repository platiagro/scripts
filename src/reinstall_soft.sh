#!/bin/bash

VERSION=0.3.0

sudo docker pull platiagro/dex-auth:$VERSION-SNAPSHOT
sudo docker pull platiagro/datasets:$VERSION-SNAPSHOT
sudo docker pull platiagro/projects:DEVELOP
sudo docker pull platiagro/persistence-agent:$VERSION-SNAPSHOT
sudo docker pull platiagro/web-ui:DEVELOP
sudo docker pull platiagro/platiagro-notebook-image:$VERSION
sudo docker pull platiagro/platiagro-experiment-image:$VERSION
sudo docker pull platiagro/platiagro-deployment-image:$VERSION
sudo docker pull platiagro/platiagro-monitoring-image:$VERSION

kubectl -n platiagro delete pod -l app=datasets
kubectl -n platiagro delete pod -l app=projects
kubectl -n platiagro delete pod -l app=persistence-agent
kubectl -n platiagro delete pod -l app=web-ui
kubectl -n anonymous delete pod server-0

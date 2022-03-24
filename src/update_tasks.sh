#!/bin/bash

sudo docker pull platiagro/tasks:0.2.0-SNAPSHOT

MYSQL=$(kubectl -n platiagro get pod -l app=mysql -o jsonpath={.items..metadata.name})
kubectl -n platiagro exec -i $MYSQL -- mysql platiagro -e "delete from operators; delete from responses; delete from comparisons; delete from monitorings; delete from deployments; delete from experiments; delete from projects; delete from tasks;" --password=PlatIAgro;

MYSQL=$(kubectl -n kubeflow get pod -l app=mysql -o jsonpath={.items..metadata.name})
kubectl -n kubeflow exec -i $MYSQL -c mysql -- mysql mlpipeline -e "delete from run_details; delete from experiments;";

COUNT=$(kubectl -n anonymous get notebooks server -o yaml|grep '\- mountPath:'|wc -l)
COUNT="$(($COUNT-1))"

STR="["
for I in `seq ${COUNT} -1 2`; do
STR+='{"op":"remove","path":"/spec/template/spec/containers/0/volumeMounts/'
STR+="$I"
STR+='"},'
STR+='{"op":"remove","path":"/spec/template/spec/volumes/'
STR+="$I"
STR+='"},'
done
STR=$(echo $STR | sed 's/.$//')
STR+=']'
echo $STR
kubectl --v=8 -n anonymous patch notebooks server --type=json -p ${STR}

kubectl -n anonymous get sdep|awk '{print $1}'|xargs -L1 kubectl -n anonymous delete sdep
kubectl -n anonymous get workflows|awk '{print $1}'|xargs -L1 kubectl -n anonymous delete workflows

kubectl -n anonymous get configmap|awk '{print $1}'|grep configmap-|xargs -L1 kubectl -n anonymous delete configmap

kubectl -n anonymous get pvc|grep vol-task-|awk '{print $1}'|xargs -L1 kubectl -n anonymous delete pvc

kubectl -n platiagro delete job init-tasks

cat <<EOF | kubectl -n platiagro create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: init-tasks
  namespace: platiagro
spec:
  template:
    spec:
      containers:
      - command:
        - python
        - /app/main.py
        image: platiagro/tasks:0.2.0-SNAPSHOT
        name: init-tasks
        env:
        - name: MYSQL_DB_HOST
          value: "mysql.platiagro"
        - name: MYSQL_DB_NAME
          value: "platiagro"
        - name: MYSQL_DB_USER
          value: "root"
        - name: MYSQL_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secrets
              key: MYSQL_ROOT_PASSWORD
      restartPolicy: OnFailure
      serviceAccountName: platiagro
EOF

sleep 5
kubectl -n platiagro wait --for=condition=complete --timeout=600s job/init-tasks

MYSQL=$(kubectl -n platiagro get pod -l app=mysql -o jsonpath={.items..metadata.name})

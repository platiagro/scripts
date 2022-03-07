#!/bin/bash

installation_mode="$1"

if [$installation_mode = ""] ; then
    echo 'missing $installation_mode'
    exit 0
fi

sudo kubeadm reset -f
rm -rf $HOME/.kube
for i in `seq 0 200`; do sudo rm -rf /l/disk0/disk-$i/* /mnt/disks/disk-$i/*; done

export KUBEFLOW_MASTER_IP_ADDRESS=$(ifconfig|grep -Po 10.1.0.[0-9]+|head -n 1)

sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo kubeadm init

sudo sed -i '/^    - --service-account-key-file.*/a \ \ \ \ - --service-account-issuer=kubernetes.default.svc' /etc/kubernetes/manifests/kube-apiserver.yaml
sudo sed -i '/^    - --service-account-key-file.*/a \ \ \ \ - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key' /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 30

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl taint nodes --all node-role.kubernetes.io/master-

sleep 15

kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/l/disk0/platiagro/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
EOF

kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

cat <<EOF | kubectl apply -f -
---
# Source: provisioner/templates/provisioner.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-provisioner-config
  namespace: default
  labels:
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2
data:
  storageClassMap: |
    local-storage:
       hostDir: /mnt/disks
       mountDir: /mnt/disks
       blockCleanerCommand:
         - "/scripts/shred.sh"
         - "2"
       volumeMode: Filesystem
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: local-volume-provisioner
  namespace: default
  labels:
    app: local-volume-provisioner
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2
spec:
  selector:
    matchLabels:
      app: local-volume-provisioner
  template:
    metadata:
      labels:
        app: local-volume-provisioner
    spec:
      serviceAccountName: local-storage-admin
      containers:
        - image: "quay.io/external_storage/local-volume-provisioner:v2.3.2"
          name: provisioner
          securityContext:
            privileged: true
          env:
          - name: MY_NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: MY_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: JOB_CONTAINER_IMAGE
            value: "quay.io/external_storage/local-volume-provisioner:v2.3.2"
          volumeMounts:
            - mountPath: /etc/provisioner/config
              name: provisioner-config
              readOnly: true
            - mountPath: /dev
              name: provisioner-dev
            - mountPath: /mnt/disks
              name: disks
              mountPropagation: "HostToContainer"
      volumes:
        - name: provisioner-config
          configMap:
            name: local-provisioner-config
        - name: provisioner-dev
          hostPath:
            path: /dev
        - name: disks
          hostPath:
            path: /mnt/disks

---
# Source: provisioner/templates/provisioner-service-account.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: local-storage-admin
  namespace: default
  labels:
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2

---
# Source: provisioner/templates/provisioner-cluster-role-binding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: local-storage-provisioner-pv-binding
  labels:
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2
subjects:
- kind: ServiceAccount
  name: local-storage-admin
  namespace: default
roleRef:
  kind: ClusterRole
  name: system:persistent-volume-provisioner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: local-storage-provisioner-node-clusterrole
  labels:
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: local-storage-provisioner-node-binding
  labels:
    heritage: "Tiller"
    release: "release-name"
    chart: provisioner-2.3.2
subjects:
- kind: ServiceAccount
  name: local-storage-admin
  namespace: default
roleRef:
  kind: ClusterRole
  name: local-storage-provisioner-node-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $KUBEFLOW_MASTER_IP_ADDRESS-$KUBEFLOW_MASTER_IP_ADDRESS
EOF

rm -rf manifests
git clone --single-branch --branch v0.3.0-kubeflow-v1.3-branch https://github.com/platiagro/manifests.git
cd manifests && while ! kustomize build $installation_mode | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

kubectl label namespace anonymous knative-eventing-injection=enabled

kubectl -n platiagro wait --for=condition=complete --timeout=600s job/init-tasks

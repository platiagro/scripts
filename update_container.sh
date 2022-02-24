pod="$1"
tag="$2"
kubectl -n platiagro set image deployment/$pod $pod=docker.io/platiagro/$pod:$tag

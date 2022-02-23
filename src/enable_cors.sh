kubectl get deployments -A | awk '{if (NR!=1) {print " -n " $1 " set env deployment/" $2 " ENABLE_CORS=1"}}' | xargs -L 1 kubectl

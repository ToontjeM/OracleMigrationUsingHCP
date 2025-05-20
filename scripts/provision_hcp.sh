#!/bin/bash

kind create cluster --config ../config/kind-config.yaml
EDB_SUBSCRIPTION_TOKEN=(`cat $HOME/tokens/.edb_subscription_token`)
EDB_PLATFORM_VERSION="v1.1.0-appl"
echo $EDB_SUBSCRIPTION_TOKEN | $SHELL scripts/install-secrets.sh -t k8s
helm repo add enterprisedb-edbpgai "https://downloads.enterprisedb.com/${EDB_SUBSCRIPTION_TOKEN}/staging_pgai-platform/helm/charts"
helm upgrade -n edbpgai-bootstrap --install --version "${EDB_PLATFORM_VERSION/-appl/+appl}" \
    -f config/kind-values.yaml \
    --set bootstrapImageTag=${EDB_PLATFORM_VERSION} \
    edbpgai-bootstrap edbpgai/edbpgai-bootstrap
while true; do
  POD_NAME=$(kubectl get pods -n edbpgai-bootstrap -o jsonpath="{.items[0].metadata.name}")
  if [ -z "$POD_NAME" ]; then
    echo "No pods found, retrying..."
    sleep 1
    continue
  fi
  STATUS=$(kubectl get pod $POD_NAME -n edbpgai-bootstrap -o jsonpath="{.status.phase}")
  if [ "$STATUS" == "Running" ]; then
    break
  fi
  sleep 1
done
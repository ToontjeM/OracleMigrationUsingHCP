#!/bin/bash
. scripts/env.sh

# Delete Postgres cluster
PROJECT_ID=$(curl -s --request GET \
  --url "https://portal-se-emea.edbhcp.com/api/v1/projects" \
  --header "x-access-key: ${ACCESS_KEY}" \
  | jq -r --arg name "$PROJECT_NAME" '.data[] | select(.projectName == $name) | .projectId')

echo $PROJECT_ID

CLUSTER_ID=$(curl -s --request GET   --url "https://portal-se-emea.edbhcp.com/api/v1/projects/${PROJECT_ID}/clusters"   --header "x-access-key: ${ACCESS_KEY}" | jq -r '.data[] | select(.name == "migrationdemo") | .clusterId')

echo $CLUSTER_ID

curl -s \
  --insecure \
  --header "Content-Type: Application/JSON" \
  --header "x-access-key: ${ACCESS_KEY}" \
  --request DELETE \
  https://portal.foo.network/api/v1/projects/${PROJECT_ID}/clusters/${CLUSTER_ID} \
  | jq

# Delete Oracle instance
ORACLE_VAGRANT_DIR=$HOME/oraclevagrant
cd $ORACLE_VAGRANT_DIR/OracleDatabase/21.3.0
vagrant destroy -f


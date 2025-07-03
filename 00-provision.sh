#!/bin/bash

REQUIRED_VARS=("ACCESS_KEY" "EDB_SUBSCRIPTION_TOKEN" "PROJECT_NAME")

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: make sure '$var' is set."
    exit 1
  fi
done

cat > ./scripts/env.sh << EOF
export ACCESS_KEY=$ACCESS_KEY
export EDB_SUBSCRIPTION_TOKEN=$EDB_SUBSCRIPTION_TOKEN
export PROJECT_NAME="${PROJECT_NAME}"
EOF

echo "Deploying Postgres instance on HM"
PROJECT_ID=$(curl -s --request GET \
  --url "https://portal-se-emea.edbhcp.com/api/v1/projects" \
  --header "x-access-key: ${ACCESS_KEY}" \
  | jq -r --arg name "$PROJECT_NAME" '.data[] | select(.projectName == $name) | .projectId')

if [ -z "PROJECT_ID" ]; then
  echo "Error: I cannot find project ${PROJECT_NAME} on the HM."
  exit 1
fi

rm ./config/migration_cluster.json
cat >> ./config/migration_cluster.json << EOF
{
    "psr": {
        "clusterName":"migrationdemo",
        "password": "enterprisedb",
        "location_id": "managed-default-location",
        "clusterData": {
            "instances": 1,
            "resourceRequest": {
                "request": {
                    "memory": "4Gi",
                    "cpu": 2
                }
            },
            "storageConfiguration": {
                "primaryStorage": {
                    "size": "10",
                    "storageClass": "gp2"
                },
                "walStorage": {
                    "size": "10",
                    "storageClass": "gp2"
                }
            },
            "image": {
              "url": "docker.enterprisedb.com/pgai-platform/edb-postgres-advanced:17.5-2506091630-full",
              "digest": "sha256:73a6ec7389f90dbab0e76d221a5ed2427be73ac264ab32546f877b18a638ce45"
            },
            "backupRetentionPeriod": "1d",
            "backupSchedule": "0 20 4 * * *",
            "networkAccessType": "NetworkAccessTypePublic"
        }
    },
    "projectId": "${PROJECT_ID}"
}
EOF

curl -s \
  --insecure \
  --header "Content-Type: Application/JSON" \
  --header "x-access-key: ${ACCESS_KEY}" \
  --data-binary "@config/migration_cluster.json" \
  --request POST \
  https://portal-se-emea.edbhcp.com/api/v1/projects/${PROJECT_ID}/clusters \
  | jq

echo "Deploying Oracle VM..."
ORACLE_VAGRANT_DIR=$HOME/oraclevagrant
cd $ORACLE_VAGRANT_DIR/OracleDatabase/21.3.0
if ! test -f LINUX.X64_213000_db_home.zip ; then
  echo "LINUX.X64_213000_db_home.zip does not exist. Please download this file from the Oracle website and place it in ${ORACLE_VAGRANT_DIR}"
  break
fi

cp $OLDPWD/config/Vagrantfile $ORACLE_VAGRANT_DIR/OracleDatabase/21.3.0
cp $OLDPWD/config/env.local .env.local
cp $OLDPWD/scripts/* userscripts

vagrant up

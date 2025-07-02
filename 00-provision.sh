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

ORACLE_VAGRANT_DIR=$HOME/oraclevagrant

cd $ORACLE_VAGRANT_DIR/OracleDatabase/21.3.0
if ! test -f LINUX.X64_213000_db_home.zip ; then
  echo "LINUX.X64_213000_db_home.zip does not exist. Please download this file from the Oracle website and place it in ${ORACLE_VAGRANT_DIR}"
  break
fi

cp $OLDPWD/config/Vagrantfile $ORACLE_VAGRANT_DIR/OracleDatabase/21.3.0
cp $OLDPWD/config/env.local .env.local
cp $OLDPWD/scripts/* userscripts


echo "Deploying Oracle VM..."
vagrant up

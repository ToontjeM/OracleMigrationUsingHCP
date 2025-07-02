#!/bin/bash

ORACLE_VAGRANT_DIR=$HOME/oraclevagrant

cd $ORACLE_VAGRANT_DIR/OracleDatabase/19.3.0
if ! test -f LINUX.X64_193000_db_home.zip ; then
  echo "LINUX.X64_193000_db_home.zip does not exist. Please download this file from the Oracle website and place it in ${ORACLE_VAGRANT_DIR}"
  break
fi

cp $OLDPWD/config/Vagrantfile $ORACLE_VAGRANT_DIR/OracleDatabase/19.3.0
cp $OLDPWD/config/env.local .env.local
cp $OLDPWD/scripts/01_deploy_hrplus_schema.sql userscripts

echo "Deploying Oracle VM..."
vagrant up

# Install beacon agent on Oracle
# Enroll Oracle instancce in HCP

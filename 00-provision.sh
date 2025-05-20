#!/bin/bash

ORACLE_VAGRANT_DIR=$HOME/oraclevagrant

source scripts/provision_hcp.sh &
cd $ORACLE_VAGRANT_DIR/OracleDatabase/19.3.0
if ! test -f LINUX.X64_193000_db_home.zip ; then
  echo "LINUX.X64_193000_db_home.zip does not exist. Please download this file from the Oracle website and place it in ${ORACLE_VAGRANT_DIR}"
  break
fi

cp $OLDPWD/config/env.local .env.local
cp $OLDPWD/scripts/01_deploy_hrplus_schema.sql userscripts
vagrant up


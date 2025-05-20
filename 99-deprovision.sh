#!/bin/bash

ORACLE_VAGRANT_DIR=$HOME/oraclevagrant

kind delete clusters edbpgai
cd $ORACLE_VAGRANT_DIR/OracleDatabase/19.3.0
vagrant destroy -f
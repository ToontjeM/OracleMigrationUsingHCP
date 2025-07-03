#!/bin/bash

wget -P /tmp https://github.com/oracle-samples/db-sample-schemas/archive/refs/tags/v21.1.zip
sudo -u oracle <<EOF
unzip /tmp/v21.1.zip -d /opt/oracle/product/21c/dbhome_1/demo
cd /opt/oracle/product/21c/dbhome_1/demo/db-sample-schemas-21.1
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat 
EOF
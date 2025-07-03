#!/bin/bash

. /vagrant/userscripts/env.sh

echo Project name: $PROJECT_NAME
echo Access key: $ACCESS_KEY
echo Subscription token: $EDB_SUBSCRIPTION_TOKEN

curl -1sSLf 'https://downloads.enterprisedb.com/$EDB_SUBSCRIPTION_TOKEN/enterprise/setup.rpm.sh' | sudo -E bash

sudo dnf install -y jq beacon-agent

PROJECT_ID=$(curl -s --request GET \
  --url "https://portal-se-emea.edbhcp.com/api/v1/projects" \
  --header "x-access-key: ${ACCESS_KEY}" \
  | jq -r --arg name "$PROJECT_NAME" '.data[] | select(.projectName == $name) | .projectId')

mkdir ~/.beacon
cat >> ~/.beacon/beacon-agent.yaml <<EOF
---
agent:
  access_key: $ACCESS_KEY
  beacon_server: beacon-se-emea.edbhcp.com:9443
  project_id: $PROJECT_ID
  feature_flag_interval: 10m0s
  plaintext: false
  providers:
    - onprem
  schema_providers:
    - "onprem-schema"
provider:
  onprem:
    databases:
      - resource_id: "demovagrant"
        dsn: oracle://oracle:oracle@localhost:1521/ORCLPDB1
        schema:
          enabled: true
          poll_interval: 15s 
        tags:
          - "demovagrant"
EOF

sudo cat >> /usr/lib/systemd/system/beacon-agent.service <<EOF
[Unit]
Description=Agent

After=network.target

[Service]
Type=simple

User=vagrant

WorkingDirectory=/home/vagrant/

ExecStart=/usr/local/bin/beacon-agent

Restart=on-failure
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable beacon-agent
sudo systemctl start beacon-agent
sudo journalctl -u beacon-agent -f
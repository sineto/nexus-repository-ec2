#!/bin/bash

NEXUS_RELEASE=nexus-3.41.1-01

## install dependencies
sudo yum update
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

## download nexus 3
cd /opt
sudo wget https://download.sonatype.com/nexus/3/${NEXUS_RELEASE}-unix.tar.gz
tar -xvf ${NEXUS_RELEASE}-unix.tar.gz

## configure nexus user and application
sudo adduser nexus
sudo usermode -aG wheel nexus
sudo chown -R nexus:nexus ${NEXUS_RELEASE}
sudo chown -R nexus:nexus sonartype-work
echo 'run_as_user="nexus"' >${NEXUS_RELEASE}/bin/nexus.rc

## configure nexus daemon
cat >/etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/${NEXUS_RELEASE}/bin/nexus start
ExecStop=/opt/${NEXUS_RELEASE}/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600
  
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service

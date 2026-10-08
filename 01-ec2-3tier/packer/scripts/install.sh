#!/bin/bash
set -eu

dnf install -y python3.12 python3.12-pip

mkdir -p /opt/app
cp -r /tmp/app-src/app /opt/app/app
cp /tmp/app-src/requirements.txt /opt/app/requirements.txt
python3.12 -m pip install -r /opt/app/requirements.txt

cp /tmp/app-src/app.service /etc/systemd/system/app.service
systemctl daemon-reload
systemctl enable app.service

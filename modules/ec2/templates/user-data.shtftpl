#!/bin/bash
set -euxo pipefail


yum -y update || dnf -y update
yum -y install docker || dnf -y install docker
systemctl enable --now docker


cat >/etc/systemd/system/httpbin.service <<'UNIT'
[Unit]
Description=httpbin container
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --rm --name httpbin -p ${host_port}:${container_port} ${container_image}
ExecStop=/usr/bin/docker stop httpbin

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now httpbin

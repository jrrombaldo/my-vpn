#!/usr/bin/env bash

#  further details at: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

yum update -y
yum install git  zsh curl vim -y
yum install -y docker

systemctl start docker.service
systemctl enable docker.service

mkdir -p /var/my-vpn/

docker run -itd \
    --name my-vpn \
    --privileged \
    --restart unless-stopped \
    -e OVPN_PASS=${VPN_PWD} \
    -e EXTERNAL_HOST=${VPN_ADDR} \
    -e DNS_PRIMARY=${VPN_DNS1} \
    -e DNS_SECONDARY=${VPN_DNS2} \
    -p:9999:9999 \
    -p8443:8443 \
    -p8443:8443/udp \
    -v /var/my-vpn/:/openvpnas_config \
    jrromb/openvpn:latest

echo "VPN_ADDR=${VPN_ADDR}" > /tmp/vpn-addr.tmp
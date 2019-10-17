#!/usr/bin/env bash

echo Applied: /vagrant/bootstrap-template.sh > /etc/motd
echo "    ========[ AWS ]========" >> /etc/motd
echo export AWS_ACCESS_KEY_ID="" >> /etc/motd
export AWS_SECRET_ACCESS_KEY="" >> /etc/motd
export AWS_DEFAULT_REGION="eu-central-1" >> /etc/motd

echo "    ========[ Install common packages ]========"
yum install -y -q -e 0 epel-release
yum update -y -q -e 0
yum install -y -q -e 0 yum-utils jq net-tools unzip tar curl awscli sshuttle htop git mc

echo "    ========[ Install and configure Docker ]========"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum install -y docker-ce docker-compose docker-machine
systemctl enable docker
systemctl start docker
usermod -aG docker vagrant
setenforce 0
setenforce Permissive


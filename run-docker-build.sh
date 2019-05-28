#!/bin/bash

sudo yum -y install epel-release
sudo rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
sudo rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
# cd to wherever this script is in the docker container
cd $(dirname "${BASH_SOURCE[0]}")
make rpm
# get the rpm back out of the container before it exits
cp /home/builder/rpm/x86_64/yummy-security*.rpm .


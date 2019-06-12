#!/bin/bash

# cd to wherever this script is in the docker container, build the rpm, then 
# copy it out
cd $(dirname "${BASH_SOURCE[0]}")
mkdir -p ~/rpmbuild/SOURCES

yum-builddep -y yummy-security.spec
make rpm

cp ~/rpmbuild/RPMS/x86_64/yummy-security*.rpm .

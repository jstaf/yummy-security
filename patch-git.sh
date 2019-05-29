#!/bin/bash

cd /tmp
sudo yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker wget
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-1.8.3.1.tar.gz
tar -xzf git-1.8.3.1.tar.gz
cd git-1.8.3.1
sudo make prefix=/usr/local install


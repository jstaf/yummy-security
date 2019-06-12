FROM centos:6

# install base rpmbuild dev tools
RUN yum install -y \
    gcc gcc-c++ \
    libtool libtool-ltdl \
    make cmake \
    tar \
    pkgconfig \
    automake autoconf \
    yum-utils rpm-build

# install newer version of git
RUN yum install -y https://repo.ius.io/ius-release-el6.rpm \
    && rpm --import https://repo.ius.io/RPM-GPG-KEY-IUS-6 \
    && yum -y install git2u

# install golang from epel
RUN yum install -y epel-release \
    && rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 \
    && yum -y install golang

CMD ["/bin/bash"]

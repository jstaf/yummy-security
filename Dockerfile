ARG EL_RELEASE=6
FROM centos:${EL_RELEASE}
ARG EL_RELEASE

# install base rpmbuild dev tools
RUN yum install -y \
    gcc gcc-c++ \
    libtool libtool-ltdl \
    make cmake \
    tar \
    pkgconfig \
    automake autoconf \
    yum-utils rpm-build \
    rpmdevtools

# install newer version of git
RUN yum install -y https://repo.ius.io/ius-release-el${EL_RELEASE}.rpm \
    && rpm --import https://repo.ius.io/RPM-GPG-KEY-IUS-${EL_RELEASE} \
    && yum -y install git2u

# install golang from epel
RUN yum install -y epel-release \
    && rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${EL_RELEASE} \
    && yum -y install golang

CMD ["/bin/bash"]

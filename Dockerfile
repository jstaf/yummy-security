FROM rpmbuild/centos7:latest

RUN sudo yum -y install epel-release &&
    sudo rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 &&
    sudo yum -y install golang

CMD ["/bin/bash"]

FROM centos:8

ENV container=docker
ENV pip_packages "ansible==2.9.16"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN dnf install -y centos-release-stream --disablerepo=appstream --disablerepo=baseos \
    && dnf swap -y centos-{linux,stream}-repos --disablerepo=appstream --disablerepo=baseos \
    && dnf distro-sync -y
RUN dnf update -y \
    && dnf install -y \
        sudo \
        which \
        python3-pip \
    && dnf clean all \
    && rm -rf /var/cache/dnf/
RUN pip3 install --upgrade pip && pip3 install $pip_packages
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]

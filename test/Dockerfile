FROM quay.io/coreos-assembler/fcos:testing-devel
RUN rm -rf /etc/yum.repos.d/*
ADD ext.repo /etc/yum.repos.d/extention.repo
RUN rpm-ostree install usbguard

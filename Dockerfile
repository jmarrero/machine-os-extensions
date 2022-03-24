FROM golang as gobuild
ADD main.go .
RUN mkdir /build
RUN go build -o /build/webserver main.go

# make this build arg like https://github.com/coreos/fcos-derivation-example/blob/6973003bfb4809693b8e25b89c76ad3b70182c4a/Dockerfile#L1 ?
#FROM registry.ci.openshift.org/rhcos-devel/rhel-coreos:4.11 as os
# This will find all RPMs from 
#needs the extension.yaml
#RUN git clone https://github.com/openshift/os.git
#RUN mkdir -p /tmp/repo
#ADD rpm-ostree /usr/bin/rpm-ostree
#RUN cd os && git submodule update --init &&  rpm-ostree compose extensions --output-dir=/usr/share/rpm-ostree/extensions/ --repo /tmp/repo manifest.yaml extensions.yaml
FROM quay.io/coreos-assembler/fcos:testing-devel as os
RUN git clone https://github.com/coreos/fedora-coreos-config.git
RUN curl https://gist.githubusercontent.com/jmarrero/c8b78b3aa78ccf83415b5e31bfe51bd0/raw/2404dcaaf4f35e5167361c7ce7db0efc4d0fd46d/extensions.yaml --output fedora-coreos-config/extensions.yaml
ADD rpm-ostree /usr/bin/rpm-ostree 
RUN rpm-ostree install distribution-gpg-keys
RUN cd fedora-coreos-config && rpm-ostree compose extensions --rootfs=/ --output-dir=/usr/share/rpm-ostree/extensions/ {manifest,extensions}.yaml
RUN ls /usr/share/rpm-ostree/extensions/

FROM quay.io/centos/centos:stream8 as repo

COPY --from=os /usr/share/rpm-ostree/extensions/ /usr/share/rpm-ostree/extensions/
RUN dnf install -y createrepo_c
RUN createrepo_c /usr/share/rpm-ostree/extensions/


FROM registry.access.redhat.com/ubi8/ubi:latest
COPY --from=gobuild /build/webserver /usr/bin/webserver
COPY --from=repo /usr/share/rpm-ostree/extensions/ /usr/share/rpm-ostree/extensions/


CMD ["./usr/bin/webserver"]
EXPOSE 9666/tcp

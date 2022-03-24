FROM golang as gobuild
ADD main.go .
RUN mkdir /build
RUN go build -o /build/webserver main.go

# make this build arg like https://github.com/coreos/fcos-derivation-example/blob/6973003bfb4809693b8e25b89c76ad3b70182c4a/Dockerfile#L1 ?
FROM registry.ci.openshift.org/rhcos-devel/rhel-coreos:4.11 as os
# This will find all RPMs from 
#needs the extension.yaml
RUN curl https://raw.githubusercontent.com/openshift/os/master/extensions.yaml --output extensions.yaml
RUN rpm-ostree compose extensions --output-dir=/usr/share/rpm-ostree/extensions/ --repo /usr/share/rpm-ostree/ extensions.yaml

FROM centos as repo
COPY --from=os /usr/share/rpm-ostree/extensions/ /usr/share/rpm-ostree/extensions/
RUN dnf install -y createrepo_c
RUN createrepo_c /usr/share/rpm-ostree/extensions/


FROM registry.access.redhat.com/ubi8/ubi:latest
COPY --from=gobuild /build/webserver /usr/bin/webserver
COPY --from=repo /usr/share/rpm-ostree/extensions/ /usr/share/rpm-ostree/extensions/


CMD ["./usr/bin/webserver"]
EXPOSE 9666/tcp

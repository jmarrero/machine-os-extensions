FROM golang as gobuild
ADD main.go .
RUN mkdir /build
RUN go build -o /build/webserver main.go

# make this build arg like https://github.com/coreos/fcos-derivation-example/blob/6973003bfb4809693b8e25b89c76ad3b70182c4a/Dockerfile#L1 ?
FROM registry.ci.openshift.org/rhcos-devel/rhel-coreos:4.11 as os
# This will find all RPMs from 

#FROM registry.access.redhat.com/ubi8/ubi:latest
FROM fedora
COPY --from=gobuild /build/webserver /usr/bin/webserver
# This 
#COPY --from=os /usr/share/rpm-ostree/extensions.yaml /tmp/os-extensions.yaml
#COPY --from=os /usr/share/rpm /tmp/os-rpmdb
#RUN rpm-ostree compose extensions --from-rpmdb=/tmp/os-rpmdb /srv/extensions
RUN mkdir -p /srv/extensions/repo/fedora/releases/32/x86_64
ADD slack-4.24.0-0.1.fc21.x86_64.rpm /srv/extensions/repo/fedora/releases/32/x86_64/slack-4.24.0-0.1.fc21.x86_64.rpm
RUN dnf install -y createrepo_c
RUN createrepo_c /srv/extensions/repo/fedora/releases/32/x86_64

CMD ["./usr/bin/webserver"]
EXPOSE 9666/tcp

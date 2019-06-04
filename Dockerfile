FROM golang:1.12.0 AS builder
WORKDIR /builder/working/directory
RUN curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar zxvf - -C . && mv qemu-3.0.0+resin-arm/qemu-arm-static .


FROM arm64v8/ubuntu
LABEL maintainer="Vincent Bitter"

COPY --from=builder /builder/working/directory/qemu-arm-static /usr/bin

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y

# Install all apps
# The third line is for multi-site config (ping is for testing later)
RUN apt-get install -y pkg-config
RUN apt-get install -y attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor
RUN apt-get install -y openvpn inetutils-ping

# Set up script and run
ADD init.sh /init.sh
RUN chmod 755 /init.sh
CMD /init.sh setup

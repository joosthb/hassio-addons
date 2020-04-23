ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Joost Hendricksen <gh@hendricksen.net>

ENV LANG C.UTF-8

# Install requirements for add-on
#RUN apk add --no-cache bash jq iw hostapd networkmanager net-tools dhcp-server 
RUN apk add --no-cache bash jq iw hostapd networkmanager net-tools dnsmasq

COPY hostapd.conf /
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Joost Hendricksen <gh@hendricksen.net>

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache jq gpsd-clients gpsd chrony

COPY chrony.conf /etc/chrony/chrony.conf

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
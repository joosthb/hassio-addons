ARG BUILD_FROM
FROM $BUILD_FROM

MAINTAINER Joost Hendricksen <gh@hendricksen.net>

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache rsync autossh

COPY run.sh /
COPY ssh_config /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG LIBWEBSOCKETS_VERSION
ARG TTYD_VERSION
RUN \
    set -x \ 
    && apk add --no-cache \
        pulseaudio-utils \
        alsa-plugins-pulse \
        python3 \
        py3-pip \
        vim

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY app.py /

CMD [ "/run.sh" ]
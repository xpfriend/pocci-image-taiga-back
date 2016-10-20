FROM python:3.5.2-alpine
MAINTAINER ototadana@gmail.com

ENV ALPINE_SDK_VERSION 0.4-r3
ENV GETTEXT_VERSION 0.19.7-r3
ENV GIT_VERSION 2.8.3-r0
ENV JPEG_DEV_VERSION 8-r6
ENV LIBXML2_DEV_VERSION 2.9.4-r0
ENV LIBXSLT_DEV_VERSION 1.1.29-r0
ENV NETCAT_VERSION 1.89-r2
ENV POSTGRESQL_DEV_VERSION 9.5.4-r0
ENV LINUX_HEADERS_VERSION 4.4.6-r1
ENV TAIGA_BACK_VERSION d28846dc9efbb79f46b86bb47c0aa1a8a3455a92

ENV LIBRARY_PATH=/lib:/usr/lib

RUN apk add --no-cache \
  alpine-sdk=${ALPINE_SDK_VERSION} gettext=${GETTEXT_VERSION} git=${GIT_VERSION} \
  jpeg-dev=${JPEG_DEV_VERSION} libxml2-dev=${LIBXML2_DEV_VERSION} \
  libxslt-dev=${LIBXSLT_DEV_VERSION} linux-headers=${LINUX_HEADERS_VERSION} \
  netcat-openbsd=${NETCAT_VERSION} postgresql-dev=${POSTGRESQL_DEV_VERSION}

RUN adduser -h /taiga -D taiga \
    && mkdir /taiga/media /taiga/static \
    && git clone https://github.com/xpfriend/taiga-back.git /taiga/taiga-back \
    && cd /taiga/taiga-back \
    && git checkout pocci \
    && pip install -r requirements.txt \
    && pip install circus git+https://github.com/ototadana/taiga-contrib-ldap-auth.git \
    && echo "${TAIGA_BACK_VERSION}" > /taiga/version

RUN echo "taiga ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

COPY ./bin/. /taiga/bin/
RUN chown -R taiga:taiga /taiga
VOLUME ["/taiga/media", "/taiga/static"]
EXPOSE 8001
CMD ["/bin/sh", "/taiga/bin/start.sh"]

USER taiga

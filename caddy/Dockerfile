ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG XCADDY_VERSION

# Install Go and other dependencies required for building Caddy
RUN apk add --no-cache go git curl tar

COPY bootstrap.sh /
COPY run.sh /
# We will create a default config.json later
COPY config.json /etc/caddy/config.json

RUN chmod a+x /bootstrap.sh
RUN chmod a+x /run.sh

RUN /bootstrap.sh $BUILD_ARCH $XCADDY_VERSION

CMD ["/run.sh"]

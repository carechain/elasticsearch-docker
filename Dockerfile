FROM openjdk:8-alpine

ARG ES_VERSION=5.6.2
ARG S6_OVERLAY_VERSION=v1.20.0.0

RUN apk update && apk --no-cache add bash curl && \
    curl -J -L -o /tmp/elasticsearch.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz && \
    mkdir /opt && \
    tar xzf /tmp/elasticsearch.tar.gz -C /opt && \
    mv /opt/elasticsearch-${ES_VERSION} /opt/elasticsearch && \
    curl -J -L -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm -rf /tmp/*

COPY assets/ /

RUN addgroup elasticsearch && \
    adduser -D -h /opt/elasticsearch -G elasticsearch -s /bin/false elasticsearch && \
    chown -R elasticsearch:elasticsearch /opt/elasticsearch && \
    mkdir -p /elasticsearch/data && \
    mkdir -p /elasticsearch/logs && \
    chown -R elasticsearch:elasticsearch /elasticsearch

ENTRYPOINT ["/init"]

HEALTHCHECK --interval=60s --timeout=30s CMD /healthcheck.sh || exit 1

EXPOSE 9200 9300

VOLUME /elasticsearch/data /elasticsearch/logs

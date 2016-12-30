FROM alpine:3.5

ENV SOLR_VERSION 4.10.4
ENV SOLR solr-$SOLR_VERSION
ENV SOLR_USER solr

RUN apk add --no-cache openjdk8-jre tar && \
  addgroup -S $SOLR_USER && \
  adduser -S $SOLR_USER $SOLR_USER && \
  mkdir -p /opt/solr && \
  wget -O /opt/$SOLR.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/$SOLR.tgz && \
  tar -C /opt/solr --extract --file /opt/$SOLR.tgz --strip-components=1 && \
  rm /opt/$SOLR.tgz && \
  rm -Rf /opt/solr/docs && \
  chown -R $SOLR_USER:$SOLR_USER /opt/solr

EXPOSE 8983
WORKDIR /opt/solr/example
USER $SOLR_USER
CMD ["java", "-jar", "start.jar"]

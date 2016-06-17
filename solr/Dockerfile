FROM alpine:3.4

ENV SOLR_VERSION 4.10.4
ENV SOLR solr-$SOLR_VERSION
ENV SOLR_USER solr

RUN apk add --no-cache openjdk8-jre && \
  addgroup -S $SOLR_USER && \
  adduser -S $SOLR_USER $SOLR_USER && \
  mkdir -p /opt && \
  wget -O /opt/$SOLR.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/$SOLR.tgz && \
  tar -C /opt --extract --file /opt/$SOLR.tgz && \
  rm /opt/$SOLR.tgz && \
  ln -s /opt/$SOLR /opt/solr && \
  chown -R $SOLR_USER:$SOLR_USER /opt/solr /opt/$SOLR

EXPOSE 8983
WORKDIR /opt/solr/example
USER $SOLR_USER
CMD ["java", "-jar", "start.jar"]

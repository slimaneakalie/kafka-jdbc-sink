FROM confluentinc/cp-kafka-connect:6.2.4

ENV CONNECT_PLUGIN_PATH /usr/share/java,/etc/kafka-connect/jars,/usr/share/confluent-hub-components
ENV CONNECT_LOG4J_LOGGERS org.apache.zookeeper=ERROR,org.I0Itec.zkclient=ERROR,org.reflections=ERROR
ENV CONNECT_LOG4J_ROOT_LOGLEVEL INFO

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.2.2
RUN confluent-hub install --no-prompt norsktipping/kafka-connect-jdbc_flatten:5.5.0

CMD ["sh", "/etc/confluent/docker/run"]
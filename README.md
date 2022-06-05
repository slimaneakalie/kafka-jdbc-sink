1. Increase docker desktop memory limit at least to 8 GB
2. Run `docker build -t customized_kafka_connect .`
3. Run `docker-compose up -d`
4. Go to `localhost:8080` to adminer and connect using the following data:
* System: `Postgresql`
* Server: `db`
* Username: `user1`
* Password: `pass`
* Database: `predictions`
5. Click `Import`, use file upload, upload `predictions.sql` file and click on `Execute`
6. Visit `http://localhost:8002`, if you don't see `CONNECTIVITY ERROR`, it means that Kafka connect is running, otherwise, check the logs of kafka connect to have better visibility.
7. Run the following command to create the topic and the schema:
```
curl --location --request POST 'http://localhost:8082/topics/predictions_kafka_topic' \
--header 'Content-Type: application/vnd.kafka.avro.v2+json' \
--data-raw '{
    "value_schema": "{\"type\":\"record\",\"name\":\"predictions_value_schema\",\"fields\":[{\"default\":null,\"name\":\"category\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"text\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"created_at\",\"type\":[\"null\",\"string\"]}]}",
    "key_schema": "{\"name\":\"predictions_key_schema\",\"type\":\"long\"}",
    "records": [
        {
            "key": 1,
            "value": {
                "category": {"string": "category example 1"},
                "text": {"string": "text example 1"},
                "created_at": {"string": "2016-06-26 22:15:29"}
            }
        }
    ]
}'
```
Go to http://localhost:8000/#/cluster/default/topic/n/predictions_kafka_topic, you should see the data you just produced on the topic.

8. We can create the connector using connec-ui or just by running the following command:
```
curl --location --request POST 'http://localhost:8083/connectors' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "predictions_topic_sink_connector_12345",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "table.name.format": "predictions_table",
        "connection.password": "pass",
        "topics": "predictions_kafka_topic",
        "tasks.max": "1",
        "batch.size": "1000",
        "transforms": "timestamp",
        "transforms.timestamp.field": "created_at",
        "transforms.timestamp.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
        "delete.enabled": "false",
        "connection.user": "user1",
        "transforms.timestamp.target.type": "Timestamp",
        "connection.url": "jdbc:postgresql://db:5432/predictions",
        "insert.mode": "upsert",
        "pk.mode": "record_key",
        "pk.fields": "id",
        "transforms.timestamp.format": "yyyy-MM-dd HH:mm:ss"
    }
}'
```
9. Go to adminer on `http://localhost:8080/?pgsql=db&username=user1&db=predictions&ns=public&select=predictions_table`, you shoud see the same data from the step 6.
10. Create another record using the following command:
```
curl --location --request POST 'http://localhost:8082/topics/predictions_kafka_topic' \
--header 'Content-Type: application/vnd.kafka.avro.v2+json' \
--data-raw '{
    "value_schema": "{\"type\":\"record\",\"name\":\"predictions_value_schema\",\"fields\":[{\"default\":null,\"name\":\"category\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"text\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"created_at\",\"type\":[\"null\",\"string\"]}]}",
    "key_schema": "{\"name\":\"predictions_key_schema\",\"type\":\"long\"}",
    "records": [
        {
            "key": 2,
            "value": {
                "category": {"string": "category example 2"},
                "text": {"string": "text example 2"},
                "created_at": {"string": "2017-07-26 23:15:29"}
            }
        }
    ]
}'
```
11. Refresh the adminer page, you should see the new record on the database,
12. You can even update records using the same key. Let's change the data for the prediction `1` by running the following command:
```
curl --location --request POST 'http://localhost:8082/topics/predictions_kafka_topic' \
--header 'Content-Type: application/vnd.kafka.avro.v2+json' \
--data-raw '{
    "value_schema": "{\"type\":\"record\",\"name\":\"predictions_value_schema\",\"fields\":[{\"default\":null,\"name\":\"category\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"text\",\"type\":[\"null\",\"string\"]},{\"default\":null,\"name\":\"created_at\",\"type\":[\"null\",\"string\"]}]}",
    "key_schema": "{\"name\":\"predictions_key_schema\",\"type\":\"long\"}",
    "records": [
        {
            "key": 1,
            "value": {
                "category": {"string": "new categry"},
                "text": {"string": "new text"},
                "created_at": {"string": "2029-07-20 01:15:30"}
            }
        }
    ]
}'
```
13. Refresh the adminer page, you should see the new data on the prediction `1`.
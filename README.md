### Start services

```shell
$ docker-compose up
```

### Initialize MongoDB replica set
https://debezium.io/documentation/reference/1.9/connectors/mongodb.html

```shell
$ docker exec -it mongodb mongo -u admin -p admin --eval 'rs.initiate({_id: "debezium_rs", members:[{_id: 0, host: "mongodb:27017"}]})'
```

### Start JDBC Sink Connector or open `debezium-connector.postman_collection.json`
```shell
$ curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://127.0.0.1:8083/connectors/ -d @jdbc-sink.json
```

### Start Debezium MongoDB CDC connector or open `debezium-connector.postman_collection.json`

For MongoDb v3.x change `capture.mode` to `oplog`. https://debezium.io/documentation/reference/1.9/connectors/mongodb.html#mongodb-property-capture-mode
```shell
$ curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://127.0.0.1:8083/connectors/ -d @mongodb-source.json
```

### Insert or update example data to mongodb
```
db.products.insert({sku: "10000", category: "Gadget", name: "Samsung Galaxy s2", quantity: 10});
db.products.insert({sku: "10001", category: "Gadget", name: "Nokia 6", quantity: 10});

db.products.update({sku: "10001"}, {$set:{quantity: 5}});
```

### Now, the data in the Postgres database should also change
```shell
debeziumtest=# select * from products;
 quantity |       name        |            id            |           _id            |  sku  | category 
----------+-------------------+--------------------------+--------------------------+-------+----------
       10 | Samsung Galaxy s2 | 63f8a2cab909476648a56eda | 63f8a2cab909476648a56eda | 10000 | Gadget
       10 | Nokia 6           | 63f8a2ecb909476648a56edb | 63f8a2ecb909476648a56edb | 10001 | Gadget
(2 rows)

debeziumtest=# select * from products;
 quantity |       name        |            id            |           _id            |  sku  | category 
----------+-------------------+--------------------------+--------------------------+-------+----------
       10 | Samsung Galaxy s2 | 63f8a2cab909476648a56eda | 63f8a2cab909476648a56eda | 10000 | Gadget
        5 | Nokia 6           | 63f8a2ecb909476648a56edb | 63f8a2ecb909476648a56edb | 10001 | Gadget
(2 rows)
```

#### Reference:
- https://hevodata.com/learn/debezium-mongodb/
- https://github.com/debezium/debezium-examples/tree/1.x/unwrap-mongodb-smt
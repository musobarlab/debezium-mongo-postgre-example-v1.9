#!/bin/bash 

# TODO: This script assumes the following
# you named the container where your mongod runs 'mongo'
# you changed MONGO_INITDB_DATABASE to 'admin'
# you set MONGO_INITDB_ROOT_USERNAME to 'root'
# you set MONGO_INITDB_ROOT_PASSWORD to 'secret'
# you set the replica set name to 'debezium_rs' (--replSet)
until mongosh --host mongodb:27017 --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done

cd /
echo '
try {
    var config = {
        "_id": "debezium_rs", // TODO update this with your replica set name
        "version": 1,
        "members": [
        {
            "_id": 0,
            "host": "mongodb:27017", // TODO rename this host
            "priority": 2
        },
        ]
    };
    rs.initiate(config, { force: true });
    rs.status();
    sleep(5000);
    // creates another user
    admin = db.getSiblingDB("debeziumtest");
    admin.createUser({
        user: "debeziumtest",
        pwd:  "debeziumtest", 
        roles: [ 
          { role: "dbOwner", db: "debeziumtest" }
        ]
      }
    );
} catch(e) {
    rs.status().ok
}
' > /config-replica.js



sleep 10
# TODO update user, password, authenticationDatabase and host accordingly
mongosh -u admin -p "admin" --authenticationDatabase admin --host mongodb:27017 /config-replica.js

# if the output of the container mongo_setup exited with code 0, everything is probably okay
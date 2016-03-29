# Mongodb test utils

## Replica test
In a docker default machine, with ip 192.168.99.100

cd replica/

1. Start mongo instances: `$ docker-compose.yml up -d`
1. Configrature mongo replication: `$ ./mongo-init-repl-set.js`
1. Monit mongo: `$ mongostat --discover -h 192.168.99.100:27018`
1. Write test: `$ ./write_test.js`
1. Read test: `$ ./read_test.js`

## Mongo sharding

### Inspired by && copy from https://github.com/gianpaj/boot2docker-mongodb

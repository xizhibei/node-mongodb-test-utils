# Mongodb test utils

## Replica test

cd replica/

1. Monit mongo: `$ mongostat --discover -h <host>:<port>`
1. Write test: `$ PRIMARY_HOST=<host>:<port> ./write_test.js`
1. Read test: `$ PRIMARY_HOST=<host>:<port> ./read_test.js`

## Mongo sharding

### Inspired by && copy from https://github.com/gianpaj/boot2docker-mongodb

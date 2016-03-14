# Mongodb test utils

## Replica test

cd replica/

1. Start mongo instances: `$ docker-compose.yml up -d`
1. Configrature mongo replication: `$ ./mongo-init-repl-set.js`
1. Monit mongo: `$ mongostat --discover`
1. Write test: `$ ./write_test.js`
1. Read test: `$ ./read_test.js`

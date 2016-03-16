#!/bin/sh

 #Start mongo instances: 
docker-compose.yml up -d

 #Configrature mongo replication: 
./mongo-init-repl-set.js

 #Monit mongo: 
mongostat --discover -h 192.168.99.100:27018

 #Write test: 
./write_test.js

 #Read test: 
./read_test.js


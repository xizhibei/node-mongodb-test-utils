#!/bin/sh

 #Start mongo instances: 
docker-compose.yml up -d

 #Configrature mongo replication: 
./mongo-init-repl-set.js

 #Monit mongo: 
mongostat --discover

 #Write test: 
./write_test.js

 #Read test: 
./read_test.js


#!/bin/bash

# mongodb container tag (ie. latest) - you need to change the 'image' field in docker-compose.yml as well
MONGO_VERSION=latest
PROJECT_NAME=mongos

docker rm -f mongos
docker-compose -p $PROJECT_NAME down

docker-compose -p $PROJECT_NAME up -d
docker-compose -p $PROJECT_NAME scale rs1=3 rs2=3 cfg=3

# (equivalet to)
# docker run --name rs1_srv1 -P -d mongo mongod --noprealloc --smallfiles --replSet rs1

# get IPs of replica set containers (TODO run in loop. like ^ containers)
for i in {1..2}
do
	for j in {1..3}
	do
		export "RS${i}_${j}"=$(docker inspect -f "{{ .NetworkSettings.Networks.${PROJECT_NAME}_default.IPAddress }}" mongos_rs${i}_${j})
	done
done

echo "Initiating replica set"
docker exec -it ${PROJECT_NAME}_rs1_1 \
	mongo --quiet --eval \
	"printjson(rs.initiate({_id:'rs1',members:[{_id:0,host:'$RS1_1',priority:10},{_id:1,host:'$RS1_2'},{_id:2,host:'$RS1_3'}]}))"

echo "Initiating replica set"
docker exec -it ${PROJECT_NAME}_rs2_1 \
	mongo --quiet --eval \
	"printjson(rs.initiate({_id:'rs2',members:[{_id:0,host:'$RS2_1',priority:10},{_id:1,host:'$RS2_2'},{_id:2,host:'$RS2_3'}]}))"


# get IPs of config containers
for j in {1..3}
do
	export "CFG_${j}"=$(docker inspect -f "{{ .NetworkSettings.Networks.${PROJECT_NAME}_default.IPAddress }}" mongos_cfg_${j})
done

echo "Initiating config server"
docker exec -it ${PROJECT_NAME}_cfg_1 \
	mongo --quiet --eval \
	"printjson(rs.initiate({_id:'cfg',configsvr:true,members:[{_id:0,host:'$CFG_1',priority:10},{_id:1,host:'$CFG_2'},{_id:2,host:'$CFG_3'}]}))"


echo "Wait config server to be prepared..."
sleep 15

# start a mongos node
echo "Starting mongos..."

docker run --net ${PROJECT_NAME}_default \
           --name mongos -P -p 27017:27017 \
           -d mongo:"$MONGO_VERSION" \
           mongos --configdb cfg/"$CFG_1":27017,"$CFG_2":27017,"$CFG_3":27017 \
           --setParameter userCacheInvalidationIntervalSecs=30

read -r -d '' ADDSHARD <<- EOM
	printjson( sh.addShard('rs1/$RS1_1,$RS1_2,$RS1_3') );
	printjson( sh.addShard('rs2/$RS2_1,$RS2_2,$RS2_3') );
EOM

echo "Add shards..."

docker exec -it mongos mongo --quiet --eval "$ADDSHARD"


read -r -d '' ENABLESHARDING <<- EOM
	printjson( db.test.insert({a:1}) );
	printjson( db.test.ensureIndex( { _id:"hashed" } ) );
	printjson( db.adminCommand( { enableSharding : "test" } ) );
	printjson( sh.shardCollection( "test.test", { _id: "hashed" } ) );
EOM

echo "Enable sharding..."

docker exec -it mongos mongo --quiet --eval "$ENABLESHARDING"

# increase log level
# docker exec -it mongos:"$MONGO_VERSION" mongo --quiet --eval "printjson( db.adminCommand( { setParameter: 1, logLevel: 2 } ) );"

echo "#####################################"
echo "MongoDB Cluster is now ready to use"
echo "Connect to cluster via docker:"
echo "$ docker exec -it mongos mongo"
echo ""
echo "Connect to cluster via OS X:"
echo "$ mongo $(docker-machine ip)"

# --------------

: '
# install iptables on 3rd config srv
docker exec -it mongo_cfg_3 bash
apt-get update -qq && apt-get install -yqq iptables
# block connections (you might need to wait 30 secs until the mongos realises the config srv is down)
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
# unblock connections
iptables -F
# check from mongos log that config server is down (this can slow down operations)
docker logs -f mongos | grep $(docker inspect -f "{{ .NetworkSettings.IPAddress }}" mongo_cfg_3)
'

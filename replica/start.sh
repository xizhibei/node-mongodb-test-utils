#!/bin/sh


source ./env.sh

 #Start mongo instances:
docker-compose -p $PROJECT_NAME up -d --no-recreate

docker-compose -p $PROJECT_NAME scale secondary=${DOCKER_MONGO_SECONDARY_NUM}


echo "Wait for it..."
sleep 15

export "DOCKER_MONGO_PRIMARY_HOST"=$(docker inspect -f "{{ .NetworkSettings.Networks.${PROJECT_NAME}_default.IPAddress }}" ${PROJECT_NAME}_primary_1)

echo "Add primary $DOCKER_MONGO_PRIMARY_HOST"
docker exec -it ${PROJECT_NAME}_primary_1 mongo --quiet --eval \
   "printjson(rs.initiate({'_id': '${REPLSET_NAME}','version': 1,'members': [{'_id': 0,'host': '${DOCKER_MONGO_PRIMARY_HOST}','priority': 10}]}))"

for j in `seq ${DOCKER_MONGO_SECONDARY_NUM}`
do
	export "HOST"=$(docker inspect -f "{{ .NetworkSettings.Networks.${PROJECT_NAME}_default.IPAddress }}" ${PROJECT_NAME}_secondary_${j})
    echo "Add member $HOST"
	docker exec -it ${PROJECT_NAME}_primary_1 mongo --quiet --eval \
        "printjson(rs.add('$HOST:27017'))"
done

docker exec -it ${PROJECT_NAME}_primary_1 mongo --quiet --eval \
    "printjson(rs.status())"

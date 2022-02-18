#!/usr/bin/bash

functionality=${1:-${REDIS_CLUSTER_FUNCTION:-create}}
redis_image=${REDIS_IMAGE:-redis:latest}
redis_nodes_count=${REDIS_NODES_COUNT:-6}
redis_container_name=${REDIS_CONTAINER_NAME:-redis}
redis_cluster_replica=${REDIS_CLUSTER_REPLICA:-1}
redis_cluster_network=${REDIS_CLUSTER_NETWORK:-redis_cluster}




create () {
	if [[ $redis_nodes_count < 6  ]]
	then
			echo
			echo "Redis cluster must have at least 6 nodes and 3 masters."
			echo "export REDIS_NODES_COUNT=6"
			echo
			exit
	fi
	
	if [[ $redis_cluster_replica < 1 ]]
	then
			echo
			echo "Redis cluster must have at least 1 replica. To address this issue:"
			echo "export REDIS_CLUSTER_REPLICA=1"
			echo
			exit
	fi
	
	if [[ $redis_cluster_replica > 1 ]] && [[ $redis_nodes_count < 9 ]]
	then
			echo
			echo "In Redis cluster with more than 2 replicas, at least 9 instances are mandatory."
			echo "Each instances has 2 replicas and at least 3 masters must exist. To address thi issue:"
			echo "export REDIS_CLUSTER_REPLICA=2"
			echo "export REDIS_NODES_COUNT=9"
			echo
			exit
	fi
	
	
	
	
	
	if [[ -f redis-cluster.info  ]]
	then
			echo "Redis cluster is already configured."
			echo "if you are sure that there is not any"
			echo "docker container, remove 'redis-cluster.info' file."
			exit
	fi
	
	echo
	echo "creating redis cluster network"
	
	docker network create $redis_cluster_network &>/dev/null
	
	echo "$redis_cluster_network created successfully."
	echo
	echo "creating redis containers..."
	
	
	for cnt in `seq 1 $redis_nodes_count`
	do
	docker run -d  -v $PWD/cluster-config.conf:/usr/local/etc/redis/redis.conf \
	--name "$redis_container_name-$cnt" \
	--net $redis_cluster_network \
	$redis_image redis-server /usr/local/etc/redis/redis.conf 1>/dev/null
	
	done
	
	echo "$redis_nodes_count redis containers created successfully"
	echo
	echo "creating cluster..."
	
	
	echo 'yes' | docker run -i --rm --net $redis_cluster_network $redis_image redis-cli --cluster create \
	$(for cnt in `seq 1 $redis_nodes_count`; do
	echo -n $(docker inspect -f \
	"{{(index .NetworkSettings.Networks \"${redis_cluster_network}\").IPAddress}}" \
	$redis_container_name-$cnt):6379\ ;done) --cluster-replicas 1 1>/dev/null
	
	echo "cluster configured successfully"
	
	sleep 2s
	
	echo
	echo "connect to masters using containers' names or IPs:"
	echo
	
	rm -rf ./redis-cluster.info
	IPs=$(docker exec $redis_container_name-1 redis-cli cluster nodes|grep master|awk '{print $2}'| awk -F: '{print $1}')
	echo "Masters:"|tee -a ./redis-cluster.info
	for ip in $IPs;do docker network inspect $redis_cluster_network |grep -B 3 $ip|grep 'Name\|IPv4Address'| \
	sed 's/\"//g'|sed 's/ //g'|awk -F: '{print $2}'|sed 's/\/.*/:6379/g'|tr '\n' ' '|tr ',' ':'|sed "s/$/\n/g" |tee -a ./redis-cluster.info;done
	
	IPs=$(docker exec $redis_container_name-1 redis-cli cluster nodes|grep slave|awk '{print $2}'| awk -F: '{print $1}')
	echo "Slaves:"|tee -a ./redis-cluster.info
	for ip in $IPs;do docker network inspect $redis_cluster_network |grep -B 3 $ip|grep 'Name\|IPv4Address'| \
	sed 's/\"//g'|sed 's/ //g'|awk -F: '{print $2}'|sed 's/\/.*/:6379/g'|tr '\n' ' '|tr ',' ':'|sed "s/$/\n/g" |tee -a ./redis-cluster.info;done
	
	echo
}

remove () {

	if [[ -f redis-cluster.info  ]]
	then
		clusters=$(cat redis-cluster.info |grep -v 'Masters\|Slaves'|awk -F: '{print $1}')
		for i in $clusters; do
			docker rm -f $i
			rm -rf redis-cluster.info
		done
	else
		echo
		echo "redis-cluster.info Not found."
		echo
		exit
	fi

}

case $functionality in

	create)
		create;;
	remove)
		remove;;
	*)
		echo
		echo "This is a creating redis cluster script on docker, written by Hosein Yousefi"
		echo "<yousefi.hosein.o@gmail.com>"
		echo
		echo "./create-cluster.sh [command]"
		echo
		echo "Command:"
		echo "	create,		create a redis cluster"
		echo "	remove,		remove redis cluster"
		echo
		echo "Variables:"
		echo "	REDIS_CLUSTER_FUNCTION={create, remove},	Instead of given argument, you are able to set variable."
		echo "	REDIS_IMAGE=redis:latest,			Give the suitable redis image version."
		echo "	REDIS_NODES_COUNT=6,				For 1 replica, 6 instances must exist."
		echo "	REDIS_CLUSTER_REPLICA=1,			Number of replica for each master instance."
		echo "	REDIS_CONTAINER_NAME=redis,			Name of your instances"
		echo "	REDIS_CLUSTER_NETWORK=redis_cluster,		Name of your cluster network."
		echo
		echo "just needed to set any variable you want to change."
		echo "Redis cluster use default values for implementation."
		echo
	;;
esac
	
	
	
	
	
	
	
	
	
	
	
# Redis-cluster

[![GitHub license](https://img.shields.io/github/license/hosein-yousefii/Redis-cluster)](https://github.com/hosein-yousefii/Redis-cluster/blob/master/LICENSE)
![LinkedIn](https://shields.io/badge/style-hoseinyousefi-black?logo=linkedin&label=LinkedIn&link=https://www.linkedin.com/in/hoseinyousefi)

Creating Redis cluster on docker in a second.

!!THIS IS JUST FOR TEST ENVIRONMENT!!

!! IF YOU WANT TO USE IT IN PRODUCTION, READ THE SCRIPT CAREFULLY!!


## What is Redis?

Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache, and message broker. Redis provides data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes, and streams. Redis has built-in replication.

# Get started:

You just need to execute:
```bash
./create-cluster.sh
```

And for removing the cluster:
```bash
./create-cluster.sh remove
```

Different variables are implemented to facilitate your job:

REDIS_CLUSTER_FUNCTION={create, remove},        Instead of given argument, you are able to set variable.

REDIS_IMAGE=redis:latest,                       Give the suitable redis image version.

REDIS_NODES_COUNT=6,                            For 1 replica, 6 instances must exist.

REDIS_CLUSTER_REPLICA=1,                        Number of replica for each master instance.

REDIS_CONTAINER_NAME=redis,                     Name of your instances.

REDIS_CLUSTER_NETWORK=redis_cluster,            Name of your cluster network.


For instance:
```bash
export REDIS_CLUSTER_FUNCTION=create
export REDIS_NODES_COUNT=9
export REDIS_CLUSTER_REPLICA=2

./create-cluster.sh
```


# How to contribute:

Implementing on kubernetes would be highly beneficial. In case of any bug, make a pull request.
Copyright 2021 Hosein Yousefi <yousefi.hosein.o@gmail.com>


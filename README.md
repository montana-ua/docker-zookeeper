# Zookeeper Dockerfile
[Zookeeper](http://zookeeper.apache.org) is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

## Description
This docker file based on:  
* docker image - [oraclelinux:6.8](https://hub.docker.com/_/oraclelinux/)  
* java - [JDK 1.8.0_102](http://www.oracle.com/technetwork/java/javase/downloads/index.html)  
* Zookeeper - [3.4.9](https://github.com/apache/zookeeper/releases/tag/release-3.4.9)  

The following actions will be performed by docker build:  
* install the additional packages (git, ant, wget, tar, vim, mc, unzip, lsof)  
* zookeeper home set to /opt/zookeeper  
* zookeeper logs will be placed into /opt/zookeeper/logs  
* zookeeper dataDir will be placed into $ZOO_HOME/data/snapshot  
* zookeeper dataLogDir will be placed into $ZOO_HOME/data/transaction  
* delete all unused files (.git/ .revision/ docs/ src/ .git\* \*.txt \*.xml build/ bin/\*.txt bin/\*.cmd lib/\*.txt /lib/cobertura)  
* set TERM=xterm  

### Build an image
If you'd like to build an own image, then you should perform the following actions:  

	cd /tmp
	git clone https://github.com/intropro/zookeeper-docker.git
	cd zookeeper-docker/git checkout 3.4.9
	git checkout 3.4.9
	docker build -t zookeeper:3.4.9 .
	rm -rf /tmp/zookeeper-docker	

### Run a container
#### Quick start as a standalone server

	docker run -d --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:latest

*Example:*

	docker run -d --network host --name zookeeper intropro/zookeeper:latest

#### Quick start a simple cluster (three dedicated hosts)

**Host #1**

	docker run -d -e MYID=1 -e ZOO_SERVERS="server.<MYID>=<HOST1>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST2>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST3>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT>" --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:latest

**Host #2**

	docker run -d -e MYID=2 -e ZOO_SERVERS="server.<MYID>=<HOST1>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST2>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST3>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT>" --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:latest

**Host #3**

	docker run -d -e MYID=3 -e ZOO_SERVERS="server.<MYID>=<HOST1>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST2>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT> server.<MYID>=<HOST3>:<FOLLOWER_PORT>:<LEADER_ELECTION_PORT>" --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:latest

*Example:*

**Host #1**

	docker run -d -e MYID=1 -e ZOO_SERVERS="server.1=host1.local.com:2888:3888 server.2=host2.local.com:2888:3888 server.3=host3.local.com:2888:3888" --network host --name zookeeper intropro/zookeeper:latest

**Host #2**

	docker run -d -e MYID=2 -e ZOO_SERVERS="server.1=host1.local.com:2888:3888 server.2=host2.local.com:2888:3888 server.3=host3.local.com:2888:3888" --network host --name zookeeper intropro/zookeeper:latest

**Host #3**

	docker run -d -e MYID=3 -e ZOO_SERVERS="server.1=host1.local.com:2888:3888 server.2=host2.local.com:2888:3888 server.3=host3.local.com:2888:3888" --network host --name zookeeper intropro/zookeeper:latest


#### Quick start a simple cluster (the similar host)

*Example:*

**Host**

	docker run -d -e MYID=1 -e ZOO_CLIENT_PORT=2181 -e ZOO_SERVERS="server.1=host.local.com:2888:3888 server.2=host.local.com:2889:3889 server.3=host.local.com:2890:3890" --network host --name zookeeper-1 intropro/zookeeper:latest
	docker run -d -e MYID=2 -e ZOO_CLIENT_PORT=2182 -e ZOO_SERVERS="server.1=host.local.com:2888:3888 server.2=host.local.com:2889:3889 server.3=host.local.com:2890:3890" --network host --name zookeeper-2 intropro/zookeeper:latest
	docker run -d -e MYID=3 -e ZOO_CLIENT_PORT=2183 -e ZOO_SERVERS="server.1=host.local.com:2888:3888 server.2=host.local.com:2889:3889 server.3=host.local.com:2890:3890" --network host --name zookeeper-3 intropro/zookeeper:latest

> Please be aware that launch zookeeper cluster on a single host will not create any redundancy. It's acceptable only for development and test purposes. Multiple hosts on dedicated servers are required for PROD mode.

#### Supported environment variables

You can pass the following variables to the container:  
* JMXPORT - start a container with JMX port. Default value - none.  
* ZOO\_CLIENT\_PORT - start a container with your own clientPort. Default value - 2181.  
* ZOO\_LOG4J\_PROP - start a container with your own log4j properties. Default value - "INFO,CONSOLE,ROLLINGFILE".  
* JVMFLAGS - you can use this variable to configure JVM. For example you can dafine a JVM heap size. Default value - empty.  
* ZOO\_LOG\_DIR - define where zookeeper logs will be placed. Default value - $ZOO\_HOME/logs.  
* MYID - define myid. Required only for cluster mode. Default value - none.  
* ZOO\_SERVERS - define members for zookeeper cluster. Required only for cluster mode. Format `server.MYID=HOSTNAME:FOLLOWER_PORT:LEADER_ELECTION_PORT` Default value - none.  
* JMXLOCALONLY - Default value - false.  
* JMXDISABLE - Default value - false.  
* JMXAUTH - Default value - false.  
* JMXSSL - Default value - false.  
* JMXLOG4J - Default value - true.  


#### Use extarnal volumes to store transaction log and snapshot files

You can use external volumes to store transaction log and snapshot files.  

Create a folder for dataDir and dataLogDir on the localhost.  

	mkdir -p /volumes/sdb1/zookeeper/data

Run a docker container (example for standalone mode):

	docker run -d -v /volumes/sdb1/zookeeper/data:/opt/zookeeper/data --network host --name zookeeper intropro/zookeeper:latest

###Manage a container
A list of running containers.

	docker ps

A list of all containers.

	docker ps -a

start/stop/stats one or more containers

	docker start <YOUR_CONTAINER_NAME>
	docker stop <YOUR_CONTAINER_NAME>
	docker stats <YOUR_CONTAINER_NAME>

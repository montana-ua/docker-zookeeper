# Zookeeper Dockerfile
[Zookeeper](http://zookeeper.apache.org) is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

## Description
This docker file is based on:
* docker image - [oraclelinux:6.8](https://hub.docker.com/_/oraclelinux/)
* java - [JDK 1.8.0_102](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* Zookeeper - [3.4.9](https://github.com/apache/zookeeper/releases/tag/release-3.4.9)

The following actions will be performed by docker build:
* install the additional packages (git, ant, wget, tar, vim, mc, unzip, lsof)
* zookeeper home set to /opt/zookeeper
* zookeeper log folder set to /opt/zookeeper/logs
* zookeeper log4j properties set to 'INFO,CONSOLE,ROLLINGFILE'
* zookeeper dataDir and dataLogDir set to /opt/zookeeper/data
* zookeeper client port set to 2181
* delete all unused files (.git/ .revision/ docs/ src/ .git* *.txt *.xml build/ bin/*.txt bin/*.cmd lib/*.txt /lib/cobertura)
* set TERM=xterm

### Build an image
If you need to build your own image based on the Dockerfile from [github](https://github.com/intropro/zookeeper-docker.git), then you should perform the following actions:
```
cd /tmp
git clone https://github.com/intropro/zookeeper-docker.git
cd zookeeper-docker/
git checkout 3.4.9
docker build -t <NAME:TAG> .
cd /tmp
rm -rf /tmp/zookeeper-docker
```

*Example :*
```
docker build -t zookeeper:3.4.9 .
```

### Create a container
####Quick start as a standalone server
You can create an image for QA or DEV purposes where a zookeeper database will store data as long as a container is running.
```
docker run -d --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:3.4.9
```

*Example:*
```
docker run -d --network host --name zookeeper intropro/zookeeper:3.4.9
```

####Define  Java Heap size 
```
docker run -d -e JVMFLAGS="-XmsYOUR_HEAP_SIZE -XmxYOUR_HEAP_SIZE" --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:3.4.9
```

*Example how to launch a zookeeper container with heap size 2GB*
```
docker run -d -e JVMFLAGS="-Xms2G -Xmx2G" --network host --name zookeeper intropro/zookeeper:3.4.9
```

####Start with  JMX Port
If you need to collect the zookeeper statistics via JMX, then you can run a zookeeper container with JMXPORT option.
```
docker run -d -e JMXPORT=YOUR_JMX_PORT --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:3.4.9
```
Please note that you can give the "java.net.UnknownHostException" error if your host haven't PTR record. To avoid this exception I strongly recommned to run a container on a host with PTR record (PTR record resolves the IP address to a domain/hostname). If it's imposible you can apply the workaround and add "IPDDARESS HOSTNAME" record into your /etc/hosts file.

*Example how to add "IPDDARESS HOSTNAME" record into your /etc/hosts file (perform the command below with root privilages)*
```
echo "$(ip route get 8.8.8.8 | head -1 | sed 's/.*src //g') $(hostname)" >> /etc/hosts
```

*Example how to launch a zookeeper container with JMX port*
```
docker run -d -e JMXPORT=9999 --network host --name zookeeper intropro/zookeeper:3.4.9
```

####Use an own configuration file
You must pull a zookeeper config template from the GitHub, create a configuration folder and unpack the configuration files into created folder, before run a zookeeper container with an own configuration file.
```
cd /tmp
git clone https://github.com/intropro/zookeeper-docker.git
git checkout 3.4.9
unzip conf-template.zip
rm -rf conf-template.zip
mv configuration.xsl /opt/zookeeper/conf
mv log4j.properties /opt/zookeeper/conf
mv zoo-template.cfg /opt/zookeeper/conf/zoo.cfg
```

Set the port number where zookeeper will accept client connections.
```
sed -i -e 's/{\ZK_PORT}/YOUR_PORT_NUMBER/g' /opt/zookeeper/conf/zoo.cfg
```
*Example how to set the port number to 2181*
```
sed -i -e 's/{\ZK_PORT}/2181/g' /opt/zookeeper/conf/zoo.cfg
```

If you want to launch zookeeper in the cluster mode, then you must describe members in the configuration file and create myid file.
*Add member into a config file.*
```
echo "server.MEMBER_ID=MEMBER_IP_OR_FQDN:MEMBER_FOLLOWER_PORT:MEMBER_LEDEAR_ELECTION_PORT" >> zoo.cfg
```
*Example how to add member*
```
echo "server.1=100.64.8.11:2888:3888" >> zoo.cfg
```
Create myid file
```
echo "MEMBER_ID" > /opt/zookeeper/data/myid
```
*Example how to create myid file*
```
echo "1" > /opt/zookeeper/data/myid
```

Run a docker container with an own configuration file

```
docker run -d -v /path/to/localhost/conf/folder:/opt/zookeeper/conf --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:3.4.9
```
*Example how to run it*
```
docker run -d -v /opt/zookeeper/conf:/opt/zookeeper/conf --network host --name zookeeper intropro/zookeeper:3.4.9
```


####Use extarnal volumes to store the log and data files
You can use external volumes to store the log and data files. You must create a volume and data and log folders on a localhost before.
```
mkdir -p /opt/zookeeper/data
mkdir -p /opt/zookeeper/logs
```
The user who runs a docker container must have read/write privileges on the created folders.

Run a docker container:
```
docker run -d -v /path/to/localhost/log/folder:/opt/zookeeper/log -v /path/to/localhost/data/folder:/opt/zookeeper/data --network host --name <YOUR_CONTAINER_NAME> intropro/zookeeper:3.4.9
```
*Example how to run it*
```
docker run -d -v /opt/zookeeper/data:/opt/zookeeper/data -v /opt/zookeeper/logs:/opt/zookeeper/logs --network host --name zookeeper intropro/zookeeper:3.4.9
```


####Start a zookeeper ensemble with an own configuration file and external log and data volumes

Example of zookeeper ensemble
![zk-ensemble](/img/zk-ensemble.png)

How to run an ensemble as on the picture above with ZK client port 2181, ZK follower port 2888, ZK loeader election port 3888, Java heap size 2GB, JMX port 9999 and external logs, conf and data volumes.

Create a zookeeper home folder on the each host:
```
mkdir -p /opt/zookeeper/data
mkdir -p /opt/zookeeper/conf
mkdir -p /opt/zookeeper/logs
```
Get a config template files from GitHub:
```
cd /tmp
git clone https://github.com/intropro/zookeeper-docker.git
cd zookeeper-docker/
git checkout 3.4.9
unzip conf-template.zip
rm -rf conf-template.zip
mv configuration.xsl /opt/zookeeper/conf
mv log4j.properties /opt/zookeeper/conf
mv zoo-template.cfg /opt/zookeeper/conf/zoo.cfg
cd /tmp
rm -rf /tmp/zookeeper-docker
```
Define zookeeper client port and members list:
```
cd /opt/zookeeper/conf
sed -i -e 's/{\ZK_PORT}/2181/g' zoo.cfg
echo "server.1=100.64.8.11:2888:3888" >> zoo.cfg
echo "server.2=100.64.8.12:2888:3888" >> zoo.cfg
echo "server.3=100.64.8.13:2888:3888" >> zoo.cfg
```

Create myid file on the each host:

*Host #1*
```
echo "1" > /opt/zookeeper/data/myid
```
*Host #2*
```
echo "2" > /opt/zookeeper/data/myid
```
*Host #3*
```
echo "3" > /opt/zookeeper/data/myid
```

Run a docker container on the each host:
```
docker run -d -e JVMFLAGS="-Xms2G -Xmx2G" -e JMXPORT=9999 -v /opt/zookeeper/conf:/opt/zookeeper/conf -v /opt/zookeeper/data:/opt/zookeeper/data -v /opt/zookeeper/logs:/opt/zookeeper/logs --network host --name zookeeper intropro/zookeeper:3.4.9
```
A docker compose is an another way, how to easy run a zookeeper container.
```
cd /tmp
git clone https://github.com/intropro/zookeeper-docker.git
git checkout 3.4.9
cd zookeeper-docker/
docker-compose -f docker-compose.yml up -d
```

###Manage a container
A list of running containers.
```
docker ps
```

A list of all containers.
```
docker ps -a
```

start/stop/stats one or more containers
```
docker start <YOUR_CONTAINER_NAME>
docker stop <YOUR_CONTAINER_NAME>
docker stats <YOUR_CONTAINER_NAME>
```

#!/bin/bash

set -e

## define zookeeper environment
if [[ -z "$ZOO_CLIENT_PORT" ]]; then ZOO_CLIENT_PORT=2181; fi
if [[ -z "$ZOO_LOG_DIR" ]]; then ZOO_LOG_DIR="$ZOO_HOME/logs"; fi
if [[ -z "$ZOO_LOG4J_PROP" ]]; then ZOO_LOG4J_PROP="INFO,CONSOLE,ROLLINGFILE"; fi

# create and configure zookeeper properties file 
if [ ! -f "$ZOO_HOME/conf/$ZOO_CONFIG" ]; then
  cp "$ZOO_HOME/conf/zoo_sample.cfg" "$ZOO_HOME/conf/$ZOO_CONFIG"
  sed -i -e 's/^#.*//g' "$ZOO_HOME/conf/$ZOO_CONFIG"
  sed -i -e '/^\s*$/d' "$ZOO_HOME/conf/$ZOO_CONFIG"
  echo "autopurge.snapRetainCount=30" >> "$ZOO_HOME/conf/$ZOO_CONFIG"
  sed -i -e "s/^clientPort=.*/clientPort=$ZOO_CLIENT_PORT/g" "$ZOO_HOME/conf/$ZOO_CONFIG"

  # create dataDir and update zookeeper config
  if [ ! -d "$ZOO_HOME/data/snapshot" ]; then 
    mkdir -p "$ZOO_HOME/data/snapshot"
    sed -i -e "s|^dataDir=.*|dataDir=${ZOO_HOME}/data/snapshot|g" "$ZOO_HOME/conf/$ZOO_CONFIG"
  fi

  # create dataLogDir and update zookeeper config
  if [ ! -d "$ZOO_HOME/data/transaction" ]; then 
    mkdir -p "$ZOO_HOME/data/transaction"
    echo "dataLogDir=$ZOO_HOME/data/transaction" >> "$ZOO_HOME/conf/$ZOO_CONFIG"
  fi

  # create myid file
  if [[ -n "$MYID" ]] && [[ ! -f "$ZOO_HOME/data/snapshot/myid" ]]; then echo "$MYID" > "$ZOO_HOME/data/snapshot/myid"; fi
    
  ## generate zookeeper members list
  if [[ -n "$ZOO_SERVERS" ]]; then 
    ### remove comas and spaces
    ZOO_SERVERS=$(echo $ZOO_SERVERS | sed -E 's/,|;/ /g' | sed 's/  / /g')
    for ZOO_SERVER in $ZOO_SERVERS; do echo "$ZOO_SERVER" >> "$ZOO_HOME/conf/$ZOO_CONFIG"; done
  fi
fi

exec env ZOO_LOG4J_PROP=$ZOO_LOG4J_PROP "$@"

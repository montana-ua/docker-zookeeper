FROM oraclelinux:6.8

MAINTAINER Sergey Vergun <sverhun@intropro.com>

ENV JAVA_MAJOR=8 \
  JAVA_UPDATE=102 \
  JAVA_BUILD=14 \
  ZOO_VERSION=3.4.9 \
  ZOO_HOME="/opt/zookeeper" \
  ZOO_LOG_DIR="/opt/zookeeper/logs" \
  ZOO_CONFIG="zoo.cfg" \
  TERM=xterm

RUN mkdir -p /usr/share/info/dir && \
  yum update -y && \
  yum install -y git ant wget tar vim mc unzip lsof && \
  wget -nv --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm" -O /tmp/jdk-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm && \
  yum localinstall -y /tmp/jdk-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm && \
  rm -f /tmp/jdk-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm && \
  mkdir -p /tmp/zookeeper && \
  cd /tmp/zookeeper && \
  git clone https://github.com/apache/zookeeper.git . && \
  git checkout release-${ZOO_VERSION} && \
  ant jar && \
  mv build/lib . && \
  mv build/zookeeper*.jar . && \
  rm -rf .git/ .revision/ docs/ src/ .git* *.txt *.xml build/ bin/*.txt bin/*.cmd lib/*.txt /lib/cobertura && \
  sed -i -e 's/MaxFileSize=.*/MaxFileSize=20MB/g' conf/log4j.properties && \
  sed -i -e 's/MaxBackupIndex=.*/MaxBackupIndex=20/g' conf/log4j.properties && \
  sed -i -e 's|#\(.*MaxBackupIndex.*\)|\1|' conf/log4j.properties && \
  mkdir -p ${ZOO_HOME} && \
  cd .. && \
  mv zookeeper/* ${ZOO_HOME}/ && \
  rm -rf /tmp/zookeeper && \
  yum clean all
    
WORKDIR $ZOO_HOME

COPY docker-entrypoint.sh $ZOO_HOME
  
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/zkServer.sh", "start-foreground"]
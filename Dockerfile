FROM oraclelinux:6.8

MAINTAINER IntroPro AMPADM team <ampadm@intropro.com>

ENV JAVA_MAJOR=8 \
  JAVA_UPDATE=102 \
  JAVA_BUILD=14 \
  JAVA_HOME=/usr/java/jdk1.${JAVA_MAJOR}.0_${JAVA_UPDATE} \
  ZOOKEEPER_VERSION=3.4.9 \
  TERM=xterm

RUN 
  mkdir -p /usr/share/info/dir && \
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
  git checkout release-${ZOOKEEPER_VERSION} && \
  ant jar && \
  mv build/lib . && \
  mv build/zookeeper*.jar . && \
  rm -rf .git/ .revision/ docs/ src/ .git* *.txt *.xml build/ bin/*.txt bin/*.cmd lib/*.txt /lib/cobertura conf/ && \
  mkdir -p /opt/zookeeper/data /opt/zookeeper/conf && \
  cd .. && \
  mv zookeeper/* /opt/zookeeper/ && \
  rm -rf /tmp/zookeeper && \
  yum clean all

WORKDIR /opt/zookeeper

VOLUME ["/opt/zookeeper/conf", "/opt/zookeeper/data"]

ENTRYPOINT ["/opt/zookeeper/bin/zkServer.sh"]

CMD ["start-foreground"]

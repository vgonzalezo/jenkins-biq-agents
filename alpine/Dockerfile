FROM alpine

#WORKDIR /usr/src/app

#COPY . .
ENV MAVEN_VERSION 3.6.3
ENV M2_HOME /opt/mvn
ENV JAVA_HOME /opt/java
ENV PATH $M2_HOME/bin:$JAVA_HOME/bin:$PATH

RUN apk add tar gzip

RUN wget -qc https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz && \
    tar -C /opt -zxf openjdk-11+28_linux-x64_bin.tar.gz && \
    mv /opt/jdk-11 /opt/java

RUN wget -qc https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -C /opt -zxf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv /opt/apache-maven-$MAVEN_VERSION /opt/mvn

RUN chmod +x /opt/java
RUN ls /opt
RUN /opt/java/bin/java -version
RUN mvn --version

#EXPOSE 3000

#ENTRYPOINT /wait && npm start

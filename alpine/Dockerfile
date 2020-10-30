FROM alpine

#WORKDIR /usr/src/app

#COPY . . 
ENV M2_HOME=/opt/apache-maven-3.6.3
ENV PATH=$PATH;$M2_HOME\bin

RUN wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar -zxvf apache-maven-3.6.3-bin.tar.gz /opt

RUN mvn --version
#EXPOSE 3000

#ENTRYPOINT /wait && npm start
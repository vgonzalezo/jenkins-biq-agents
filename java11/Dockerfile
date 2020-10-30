FROM openshift/jenkins-slave-base-centos7:v3.11

ENV JAVA_VERSION=11

RUN yum -y remove $(rpm -qa | grep java)
RUN yum -y install java-11-openjdk-devel maven

USER 1001

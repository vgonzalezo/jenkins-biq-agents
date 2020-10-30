FROM openshift/jenkins-slave-base-centos7:v3.11

RUN yum -y install maven
RUN yum -y remove $(rpm -qa | grep java) 
RUN yum -y install java-11-openjdk-devel
RUN java -version

USER 1001

FROM openshift/jenkins-slave-base-centos7:v3.11

ENV JAVA_VERSION=11

RUN yum -y remove java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless

RUN INSTALL_PKGS="java-11-openjdk-devel maven" && \
    yum install -y --setopt=tsflags=nodocs \
      $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \ 
    yum clean all -y && \
    rm -rf /var/cache/yum

USER 1001

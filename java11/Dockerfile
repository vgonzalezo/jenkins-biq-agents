FROM openshift/jenkins-slave-base-centos7:v3.11

ENV JAVA_VERSION=11

RUN rpm -qa | grep openjdk | xargs  yum -y remove

RUN INSTALL_PKGS="java-11-openjdk maven" && \
    yum install -y --setopt=tsflags=nodocs \
      $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \ 
    yum clean all -y && \
    rm -rf /var/cache/yum

USER 1001

FROM openshift/jenkins-slave-base-centos7:v3.11

ENV JAVA_VERSION=11

RUN INSTALL_PKGS="openjdk11-jdk" && \
    yum install -y --setopt=tsflags=nodocs \
      $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \ 
    yum clean all -y && \
    rm -rf /var/cache/yum

USER 1001

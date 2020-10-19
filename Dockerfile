FROM openshift/jenkins-slave-base-centos7:v3.11

ENV NODEJS_VERSION=14 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

RUN curl --silent --location https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | bash -

RUN INSTALL_PKGS="nodejs Xvfb libXfont Xorg" && \
    yum install -y --setopt=tsflags=nodocs \
      $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \ 
    yum clean all -y && \
    rm -rf /var/cache/yum

USER 1001

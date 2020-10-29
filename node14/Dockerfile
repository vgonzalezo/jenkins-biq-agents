FROM openshift/jenkins-slave-base-centos7:v3.11

ENV NODEJS_VERSION=14 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    JMETER_HOME=$HOME/apache-jmeter-5.2.1 \
    PATH=$HOME/node_modules/.bin/:$NPM_CONFIG_PREFIX/bin/:$JMETER_HOME/bin:$PATH

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm google-chrome-stable_current_x86_64.rpm

RUN curl --silent --location https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | bash -

RUN INSTALL_PKGS="nodejs libXScrnSaver java-1.8.0-openjdk" && \
    yum install -y --setopt=tsflags=nodocs \
      $INSTALL_PKGS && \
    yum -y localinstall \
      google-chrome-stable_current_x86_64.rpm && \
    rm google-chrome-stable_current_x86_64.rpm && \
    rpm -V $INSTALL_PKGS && \ 
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    wget -qc http://apache.stu.edu.tw//jmeter/binaries/apache-jmeter-5.2.1.tgz && \
    tar -xf apache-jmeter-5.2.1.tgz -C $HOME/

USER 1001

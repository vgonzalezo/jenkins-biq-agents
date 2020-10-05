FROM jenkins/inbound-agent:latest

LABEL image jenkins/inbound-agent:latest
LABEL distro debian

USER root

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get update -y \
    apt install nodejs -y
#RUN apt-get clean && apt-get upgrade -y \
#    && apt-get update -y --fix-missing \
#    && apt-get -qqy --no-install-recommends install \
#    nodejs

# Set node version
ENV NODE_VERSION LATEST

# Set locale
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install node
RUN npm install -g n;
RUN n ${NODE_VERSION};

USER jenkins
ENTRYPOINT ["/bin/bash"]
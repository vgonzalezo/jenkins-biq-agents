#FROM debian:buster
FROM jenkins/inbound-agent:4.3-4
#FROM openshift/jenkins-agent-nodejs-8-centos7:v3.11
#FROM openshift/jenkins-slave-nodejs-centos7

#RUN node -v
#LABEL image jenkins/inbound-agent:4.3-4
#LABEL distro centos7

#USER root

# Install npm

#RUN curl -sL https://deb.nodesource.com/setup_current.x | bash -
#RUN apt-get clean && apt-get upgrade -y \
#    && apt-get update -y --fix-missing \
#    && apt-get -qqy --no-install-recommends install \
#    nodejs

# Set node version
#ENV NODE_VERSION 8

# Set locale
#ENV LC_ALL en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US.UTF-8

# Install node
#RUN npm install -g n;
#RUN n ${NODE_VERSION};

# Set newman version
ENV NEWMAN_VERSION 3.9.2

# Install newman
RUN npm install -g newman@${NEWMAN_VERSION}; \
    npm install -g newman-reporter-junitfull; \
    npm install -g newman-reporter-htmlextra


# Set workdir to /etc/newman
# When running the image, mount the directory containing your collection to this location
#
# docker run -v <path to collections directory>:/etc/newman ...
#
# In case you mount your collections directory to a different location, you will need to give absolute paths to any
# collection, environment files you want to pass to newman, and if you want newman reports to be saved to your disk.
# Or you can change the workdir by using the -w or --workdir flag

WORKDIR /etc/newman
RUN chmod 777 /etc/newman

# Set newman as the default container command
# Now you can run the container via
#
#   newman runcollections/xyx.json -e collections/env.json
#   newman run https://www.getpostman.com/collections/631643-f695cab7-6878-eb55-7943-ad88e1ccfd65-JsLv 
#   -r junitfull,htmlextra,cli 
#   --reporter-junitfull-export './result.xml' 
#   --reporter-htmlextra-export './report.html' 
#   -n 2
USER jenkins
ENTRYPOINT ["/bin/bash"]
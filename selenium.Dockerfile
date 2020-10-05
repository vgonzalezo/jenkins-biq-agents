#FROM debian:buster
FROM jenkins/inbound-agent:4.3-4

LABEL image jenkins/inbound-agent:4.3-4
LABEL distro debian

USER root
#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV SCREEN_DPI 96
ENV DISPLAY :99.0
ENV START_XVFB true
#================================================
# Customize sources for apt-get
#================================================
ENV LANG_WHICH en
ENV LANG_WHERE US
ENV ENCODING UTF-8
ENV LANGUAGE ${LANG_WHICH}_${LANG_WHERE}.${ENCODING}
ENV LANG ${LANGUAGE}
#========================
# Selenium Configuration
#========================
# As integer, maps to "maxInstances"
ENV NODE_MAX_INSTANCES 2
# As integer, maps to "maxSession"
ENV NODE_MAX_SESSION 2
# As address, maps to "host"
ENV NODE_HOST 0.0.0.0
# As integer, maps to "port"
ENV NODE_PORT 5555
# In milliseconds, maps to "registerCycle"
ENV NODE_REGISTER_CYCLE 5000
# In milliseconds, maps to "nodePolling"
ENV NODE_POLLING 5000
# In milliseconds, maps to "unregisterIfStillDownAfter"
ENV NODE_UNREGISTER_IF_STILL_DOWN_AFTER 60000
# As integer, maps to "downPollingLimit"
ENV NODE_DOWN_POLLING_LIMIT 2
# As string, maps to "applicationName"
ENV NODE_APPLICATION_NAME ""
# Debug
ENV GRID_DEBUG true
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN  echo "deb http://deb.debian.org/debian sid main\n" > /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian buster contrib\n" >> /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian buster non-free\n" >> /etc/apt/sources.list 

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    HOME=/home/jenkins
# Install

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends  install \
    curl \
    vim \
    unzip \
    supervisor \
    xvfb \
    pulseaudio \
    x11vnc\
    fluxbox \
    libxi6 \
    libgconf-2-4\
    default-jdk \
    libfontconfig \
    libfreetype6 \
    xfonts-cyrillic \
    xfonts-scalable \
    fonts-liberation \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-tlwg-loma-otf \
    locales \
    && locale-gen ${LANGUAGE} \
    && dpkg-reconfigure --frontend noninteractive locales \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* 

#==========
# Selenium  https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar
#==========
RUN mkdir /opt/selenium \
    && wget --no-verbose https://selenium-release.storage.googleapis.com/4.0-alpha-6/selenium-server-4.0.0-alpha-6.jar \
    -O /opt/selenium/selenium-server.jar 
#================================================
# Install Chrome-stable
#================================================
ARG CHROME_VERSION="google-chrome-stable"
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update -qqy \
    && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
#=================================
# Chrome Launch Script Wrapper
#=================================

COPY wrap_chrome_binary \
    start-xvfb.sh \
    start-fluxbox.sh \
    start-vnc.sh \
    entry_point.sh \
    start-selenium-standalone.sh \
    /opt/bin/
COPY generate_config \
    wrapper.sh \
    /opt/selenium/
COPY supervisord.conf /etc
COPY selenium.conf /etc/supervisor/conf.d/
RUN chmod -R 777 /opt/selenium/ \
    && chmod -R 777 /opt/bin/ \
    && chmod 777 /etc/supervisor/conf.d/selenium.conf \
    && chmod 777 /etc/supervisord.conf \
    # Creating base directory for Xvfb
    && mkdir -p /opt/selenium /var/run/supervisor /var/log/supervisor \
    && chmod -R 777 /opt/selenium /var/run/supervisor /var/log/supervisor /etc/passwd \
    && chgrp -R 0 /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor \
    && chmod -R g=u /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

RUN mkdir -p /home/jenkins/.vnc \
  && x11vnc -storepasswd secret /home/jenkins/.vnc/passwd \
  && chmod -R 777 /home/jenkins \
  && chgrp -R 0 ${HOME} \
  && chmod -R g=u ${HOME}

RUN /opt/bin/wrap_chrome_binary

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION
RUN if [ -z "$CHROME_DRIVER_VERSION" ]; \
  then CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && CHROME_DRIVER_VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"); \
  fi \
  && echo "Using chromedriver version: "$CHROME_DRIVER_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver


#================================================
# Install Firefox-stable and Geckodriver
#================================================
ARG FIREFOX_VERSION=latest
RUN FIREFOX_DOWNLOAD_URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"  \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install libavcodec-extra \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

ARG GECKODRIVER_VERSION=latest
RUN GK_VERSION=$(if [ ${GECKODRIVER_VERSION:-latest} = "latest" ]; then echo "0.27.0"; else echo $GECKODRIVER_VERSION; fi) \
  && echo "Using GeckoDriver version: "$GK_VERSION \
  && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
  && chmod 755 /opt/geckodriver-$GK_VERSION \
  && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver

#================================================
# Install Selenium
#================================================

RUN /opt/selenium/generate_config > /opt/selenium/config.json

USER jenkins
EXPOSE 5900
EXPOSE 4444

CMD ["/opt/bin/entry_point.sh"]

FROM phusion/baseimage:0.9.22
MAINTAINER jamesgol <james@gnuinter.net>

ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody
RUN usermod -d /config nobody

# Add default config
ADD config.yml /config.yml

RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ xenial universe multiverse" && \
    add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe multiverse" && \
    add-apt-repository "ppa:deluge-team/ppa" && \
    apt-get update -qq && \
    apt-get install -qq python3 python3-dev python3-pip python3-transmissionrpc wget deluge && \
    apt-get autoremove && \
    apt-get autoclean && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade setuptools && \
    pip3 install flexget && \ 
    pip3 install --upgrade six>=1.70 && \
    ln -sf /config /root/.flexget

VOLUME /config

# Add firstrun.sh to runit
ADD firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

# Add flexget to runit
RUN mkdir /etc/service/flexget
ADD flexget.sh /etc/service/flexget/run
RUN chmod +x /etc/service/flexget/run

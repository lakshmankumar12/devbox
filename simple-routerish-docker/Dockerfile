FROM phusion/baseimage:focal-1.2.0
MAINTAINER Lakshman Kumar <lakshmankumar@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install dev tools
RUN apt-get update && \
        apt-get install -y \
            iproute2 \
            iputils-ping \
            iptables \
            net-tools \
            bridge-utils \
            conntrack \
            ethtool \
            tcpdump \
            screen \
            strongswan \
            strongswan-swanctl \
            python3 \
            python3-pip && \
        pip install --pre scapy[basic] && \
        mkdir /var/shared/ && \
        touch /var/shared/placeholder

ADD screenrc /.screenrc

VOLUME /var/shared

## Not cleaning.. we want to continue installing in container
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Fire this container
##   docker run --rm -v $HOME:/var/shared -t -i lakshmankumar/simple-routerish-docker /sbin/my_init -- bash -l

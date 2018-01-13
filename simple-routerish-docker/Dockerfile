FROM phusion/baseimage:0.9.22
MAINTAINER Lakshman Kumar <lakshmankumar@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install dev tools
RUN apt-get update

RUN apt-get install -y \
        iproute2 \
        iputils-ping \
        iptables \
        tcpdump \
        python \
        curl \
        screen \
        openssh-server \
        python-pip

RUN echo "root:rPasswd!" | chpasswd; \
        sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
        echo "export VISIBLE=now" >> /etc/profile;

RUN mkdir /var/shared/ && \
    touch /var/shared/placeholder

VOLUME /var/shared

CMD ["/bin/bash"]

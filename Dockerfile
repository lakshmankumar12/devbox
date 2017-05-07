FROM ubuntu:latest
MAINTAINER Lakshman Kumar <lakshmankumar@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

# Install dev tools
RUN apt-get update && apt-get install -y \
            apt-utils \
            locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    echo 'LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8' >> /etc/environment && \
    apt-get install -y git \
            sudo \
            python \
            wget \
            curl \
            man \
            unzip \
            zsh \
            vim \
            strace \
            diffstat \
            pkg-config \
            cmake \
            build-essential \
            tcpdump \
            iputils-ping \
            tmux \
            cscope \
            ctags \
            rubygems && \
    gem install asciidoctor

# More tools
RUN dpkg --add-architecture i386 && \
         apt-get update && \
         apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 && \
         apt-get install -y python-pip ppp  openssh-server && \
         pip install pexpect

RUN echo "root:Docker!" | chpasswd; \
        sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
        echo "export VISIBLE=now" >> /etc/profile;

# Create user and add home-dir and github dir
RUN useradd lakshman && mkdir /home/lakshman && \
                        mkdir /home/lakshman/github && \
                        chown -R lakshman: /home/lakshman

ENV HOME /home/lakshman
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN echo "lakshman:lakshman" | chpasswd  && \
     adduser lakshman sudo

# reach outside world
RUN mkdir /var/shared/ && \
    touch /var/shared/placeholder && \
    ln -s /var/shared /home/lakshman/host && \
    chown -R lakshman:lakshman /var/shared && \
    chown -R lakshman:lakshman /home/lakshman/host
VOLUME /var/shared

USER lakshman
WORKDIR /home/lakshman

# lets get our vimfiles and setup vim
RUN git clone https://github.com/lakshmankumar12/vimfiles /home/lakshman/github/vimfiles &&  \
       git clone https://github.com/lakshmankumar12/vundle-headless-installer.git /home/lakshman/github/vundle-headless-installer && \
       mkdir -p /home/lakshman/.vim/plugin && \
       ln -s /home/lakshman/github/vimfiles/lakshman.vim /home/lakshman/.vim/plugin/lakshman.vim && \
       mkdir -p /home/lakshman/.vim/bundle/ && \
       ln -s /home/lakshman/github/vimfiles/vimrc /home/lakshman/.vimrc && \
       echo "comment"

RUN python /home/lakshman/github/vundle-headless-installer/install.py && \
       chown -R lakshman: /home/lakshman

USER root
COPY entrypoint.sh /home/lakshman/.entrypoint.sh
RUN chown lakshman:lakshman /home/lakshman/.entrypoint.sh && chmod +x /home/lakshman/.entrypoint.sh

RUN apt-get install -y psmisc lsof

USER lakshman

EXPOSE 22

ENTRYPOINT ["/home/lakshman/.entrypoint.sh"]
CMD ["bash"]

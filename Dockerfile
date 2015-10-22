FROM ubuntu:latest
MAINTAINER Lakshman Kumar <lakshmankumar@gmail.com>

# Install dev tools
RUN apt-get update && apt-get install -y \
            git \
            python \
            wget \
            vim \
            strace \
            diffstat \
            pkg-config \
            cmake \
            build-essential \
            tcpdump \
            tmux \
            curl \
            cscope \
            ctags

# Create user and add home-dir and github dir
RUN useradd lnara002 && mkdir /home/lnara002 && \
                        chown -R lnara002: /home/lnara002 && \
                        mkdir /home/lnara002/github

ENV HOME /home/lnara002

# lets get our vimfiles and setup vim
RUN git clone https://github.com/lakshmankumar12/vimfiles /home/lnara002/github/vimfiles &&  \
       git clone https://github.com/lakshmankumar12/vundle-headless-installer.git /home/lnara002/github/vundle-headless-installer && \
       mkdir -p /home/lnara002/.vim/plugin && \
       ln -s /home/lnara002/github/vimfiles/lakshman.vim /home/lnara002/.vim/plugin/lakshman.vim && \
       mkdir -p /home/lnara002/.vim/bundle/ && \
       ln -s /home/lnara002/github/vimfiles/vimrc /home/lnara002/.vimrc && \
       python /home/lnara002/github/vundle-headless-installer/install.py && \
       chown -R lnara002: /home/lnara002

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
RUN echo "lnara002:lnara002" | chpasswd  && \
     adduser lnara002 sudo

# reach outside world
RUN mkdir /var/shared/ && \
    touch /var/shared/placeholder && \
    chown -R lnara002:lnara002 /var/shared
VOLUME /var/shared

USER lnara002
WORKDIR /home/lnara002
EXPOSE 22
CMD ["bash"]

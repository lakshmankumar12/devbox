FROM ubuntu:14.04

# Install dev tools
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y python
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get install -y strace
RUN apt-get install -y diffstat
RUN apt-get install -y pkg-config
RUN apt-get install -y cmake
RUN apt-get install -y build-essential
RUN apt-get install -y tcpdump
RUN apt-get install -y tmux

RUN useradd lnara002
RUN mkdir /home/lnara002 && chown -R lnara002: /home/lnara002
RUN mkdir /home/lnara002/github

# lets get our vimfiles
workdir /home/lnara002/github
RUN git clone https://github.com/lakshmankumar12/vimfiles
RUN ln -s /home/lnara002/github/vimfiles/vimrc /home/lnara002/.vimrc

workdir /home/lnara002
env HOME /home/lnara002

run mkdir /var/shared/
run touch /var/shared/placeholder
run chown -R lnara002:lnara002 /var/shared
volume /var/shared

user lnara002

CMD ["bash"]

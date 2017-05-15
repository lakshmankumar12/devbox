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
            psmisc \
            lsof \
            wget \
            curl \
            man \
            ghostscript \
            imagemagick \
            id3v2 \
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
         pip install pexpect && \
         pip install eyeD3

RUN echo "root:Docker!" | chpasswd; \
        sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
        echo "export VISIBLE=now" >> /etc/profile;

RUN bash -c "curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl" && \
    chmod +x /usr/local/bin/youtube-dl

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
    chown -R lakshman:lakshman /home/lakshman/host && \
    chsh -s /usr/bin/zsh lakshman
VOLUME /var/shared

WORKDIR /home/lakshman

# lets get our vimfiles and setup vim
RUN git clone https://github.com/lakshmankumar12/vimfiles /home/lakshman/github/vimfiles &&  \
       git clone https://github.com/lakshmankumar12/vundle-headless-installer.git /home/lakshman/github/vundle-headless-installer && \
       git clone https://github.com/lakshmankumar12/zsh-git-prompt.git /home/lakshman/github/zsh-git-prompt && \
       git clone https://github.com/lakshmankumar12/dotfiles /home/lakshman/github/dotfiles && \
       bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
       bash -c "cd /home/lakshman/.oh-my-zsh && patch -p1 -i <(curl 'https://gist.githubusercontent.com/lakshmankumar12/5d6abf8a93cc9afcbffe98cb38e362be/raw/74cafc1c1571fbd6639098d99a48d3d28de73404/agnoster.patch')" && \
       echo "comment to be edited, if u want to github get ur repo again on its change - blah blah"

RUN mkdir -p /home/lakshman/.vim/plugin && \
       mkdir -p /home/lakshman/.vim/bundle/ && \
       ln -s /home/lakshman/github/vimfiles/vimrc /home/lakshman/.vimrc && \
       python /home/lakshman/github/vundle-headless-installer/install.py

RUN sed 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' -i /home/lakshman/.zshrc && \
       ln -s /home/lakshman/github/vimfiles/lakshman.vim /home/lakshman/.vim/plugin && \
       ln -s /home/lakshman/github/vimfiles/gitlsfiles.vim /home/lakshman/.vim/plugin && \
       ln -s /home/lakshman/github/dotfiles/bashrc.local /home/lakshman/.bashrc.local && \
       ln -s /home/lakshman/github/dotfiles/gitconfig /home/lakshman/.gitconfig && \
       ln -s /home/lakshman/github/dotfiles/tmux.conf /home/lakshman/.tmux.conf && \
       ln -s /home/lakshman/github/dotfiles/zshrc.local /home/lakshman/.zshrc.local && \
       ln -s /home/lakshman/github/dotfiles/bashrc_for_zsh /home/lakshman/.bashrc_for_zsh

COPY entrypoint.py /home/lakshman/.entrypoint.py
COPY entrypoint.sh /home/lakshman/.entrypoint.sh
RUN chown -R lakshman:lakshman /home/lakshman && chmod +x /home/lakshman/.entrypoint.sh

USER lakshman

RUN echo "source ~/.zshrc.local" >> /home/lakshman/.zshrc && \
      mkdir /home/lakshman/bin && \
      git clone --depth 1 https://github.com/junegunn/fzf.git /home/lakshman/.fzf && \
      /home/lakshman/.fzf/install --bin && \
      ln -s /home/lakshman/.fzf/bin/fzf /home/lakshman/bin/fzf && \
      ln -s /home/lakshman/.fzf/bin/fzf-tmux /home/lakshman/bin/fzf-tmux

RUN mkdir /home/lakshman/software && \
    git clone --depth 1 https://github.com/seebi/dircolors-solarized.git /home/lakshman/software/dircolors-solarized && \
    git clone --depth 1 https://github.com/lakshmankumar12/tmux-status-notify /home/lakshman/github/tmux-status-notify && \
    git clone --depth 1 https://github.com/lakshmankumar12/tmux-powerline.git /home/lakshman/software/tmux-powerline && \
    rm /home/lakshman/software/tmux-powerline/segments/lk_notif_info.sh && \
    ln -s /home/lakshman/github/tmux-status-notify/lk_notif_info.sh /home/lakshman/software/tmux-powerline/segments/lk_notif_info.sh && \
    ln -s /usr/bin/vim /home/lakshman/bin/vim


EXPOSE 22

ENTRYPOINT ["/home/lakshman/.entrypoint.sh"]

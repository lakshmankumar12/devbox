FROM ubuntu:bionic
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
            pkg-config \
            cmake \
            build-essential \
            libreadline7 \
            libreadline-dev \
            python \
            python3 \
            ppp  \
            openssh-server \
            psmisc \
            lsof \
            wget \
            curl \
            man \
            ghostscript \
            imagemagick \
            ffmpeg \
            id3v2 \
            unzip \
            zsh \
            vim \
            strace \
            diffstat \
            tcpdump \
            iputils-ping \
            tmux \
            cscope \
            ctags \
            software-properties-common \
            expect \
            gdb \
            poppler-utils \
            gparted dosfstools udev \
            wireshark silversearcher-ag \
            vpnc libxss1 libappindicator1 libindicator7 sshfs \
            mosh \
            rubygems \
            ruby-dev \
            dbus-x11 \
            pandoc \
            clang libclang-dev libssl-dev zlib1g-dev asciinema teseq \
            deluge

RUN apt-get install -y python3-distutils

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && python /tmp/get-pip.py && python3 /tmp/get-pip.py

RUN add-apt-repository ppa:neovim-ppa/stable -y
RUN apt-get update
RUN apt-get -y install neovim
RUN bash -c "curl -sL https://deb.nodesource.com/setup_8.x | bash -"
RUN apt-get -y install nodejs

RUN  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
              ( dpkg -i google-chrome*.deb || true ) && \
              sudo apt-get install -y -f &&  \
              sudo dpkg -i google-chrome*.deb

RUN gem install asciidoctor neovim

RUN pip install pexpect eyeD3 pathlib gmusicapi grako && \
    pip3 install flask_oauthlib flask_script

# More tools
#RUN dpkg --add-architecture i386 && \
#apt-get update && \
#apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 && \

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
RUN git clone --depth 1 https://github.com/lakshmankumar12/vimfiles /home/lakshman/github/vimfiles &&  \
       git clone --depth 1 https://github.com/lakshmankumar12/vundle-headless-installer.git /home/lakshman/github/vundle-headless-installer && \
       git clone --depth 1 https://github.com/lakshmankumar12/zsh-git-prompt.git /home/lakshman/github/zsh-git-prompt && \
       git clone --depth 1 https://github.com/lakshmankumar12/dotfiles /home/lakshman/github/dotfiles && \
       bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
       bash -c "cd /home/lakshman/.oh-my-zsh && patch -p1 -i <(curl 'https://gist.githubusercontent.com/lakshmankumar12/5d6abf8a93cc9afcbffe98cb38e362be/raw/9c2216bc5a53814c8e610774ef9d849893ad6c3c/agnoster.patch')" && \
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

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Any new root installs here
RUN apt-get update
RUN apt-get update
RUN apt-get install -y python-tk python3-tk w3m qpdf python-dev python3-dev

#pdftk is from previous ubuntu version
RUN wget http://launchpadlibrarian.net/340410966/libgcj17_6.4.0-8ubuntu1_amd64.deb \
         http://launchpadlibrarian.net/337429932/libgcj-common_6.4-3ubuntu1_all.deb \
         https://launchpad.net/ubuntu/+source/pdftk/2.02-4build1/+build/10581759/+files/pdftk_2.02-4build1_amd64.deb \
         https://launchpad.net/ubuntu/+source/pdftk/2.02-4build1/+build/10581759/+files/pdftk-dbg_2.02-4build1_amd64.deb && \
    apt-get install -y ./libgcj17_6.4.0-8ubuntu1_amd64.deb \
        ./libgcj-common_6.4-3ubuntu1_all.deb \
        ./pdftk_2.02-4build1_amd64.deb \
        ./pdftk-dbg_2.02-4build1_amd64.deb && \
    rm ./libgcj17_6.4.0-8ubuntu1_amd64.deb && \
    rm ./libgcj-common_6.4-3ubuntu1_all.deb && \
    rm ./pdftk_2.02-4build1_amd64.deb && \
    rm ./pdftk-dbg_2.02-4build1_amd64.deb

#Root install ..over..

RUN chown -R lakshman:lakshman /home/lakshman
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
    git clone --depth 1 https://github.com/joelthelion/autojump.git /home/lakshman/software/autojump && \
    rm /home/lakshman/software/tmux-powerline/segments/lk_notif_info.sh && \
    ln -s /home/lakshman/github/tmux-status-notify/lk_notif_info.sh /home/lakshman/software/tmux-powerline/segments/lk_notif_info.sh && \
    ln -s /usr/bin/vim /home/lakshman/bin/vim



#Any new lakshman installs here
RUN pip2 install --user neovim beautifulsoup4 scipy matplotlib lxml selenium pylyrics lyricwikia mutagen pexpect
RUN pip3 install --user neovim beautifulsoup4 scipy matplotlib lxml selenium pylyrics lyricwikia mutagen pexpect
RUN pip3 install --user ipython
RUN ln -s /home/lakshman/.local/bin/ipython3 /home/lakshman/bin/

USER root
COPY entrypoint.sh /home/lakshman/.entrypoint.sh
RUN chown lakshman:lakshman /home/lakshman/.entrypoint.sh && chmod +x /home/lakshman/.entrypoint.sh

EXPOSE 22
EXPOSE 51413

ENTRYPOINT ["/home/lakshman/.entrypoint.sh"]

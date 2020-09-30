FROM ubuntu:bionic

ENV USER docker
ENV HOME_PATH /home/$USER
ENV PROFILE_FILE $HOME_PATH/.zshrc

# Use bash instead of sh for shell commands
SHELL ["/bin/bash", "-c"]

# Tell apt-get not to prompt for input (especially for tzdata install)
ENV DEBIAN_FRONTEND=noninteractive

# install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-utils \
  autoconf \
  bison \
  build-essential \
  bzip2 \
  ca-certificates \
  curl \
  dirmngr \
  git \
  gnupg \
  imagemagick \
  inetutils-ping \
  less \
  libdb-dev \
  libffi-dev \
  libgdbm-dev\
  libgdbm5 \
  libmemcached-dev \
  libmysqlclient-dev \
  libncurses5-dev \
  libpq-dev \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libyaml-dev \
  lsb-release \
  netbase \
  openssh-client \
  procps \
  socat \
  sudo \
  tmux \
  tree \
  tzdata \
  vim \
  wget \
  zlib1g-dev \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Create the user and assign it to the sudo group
RUN useradd -m $USER && echo "$USER:$USER" | chpasswd && adduser $USER sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set shell as zsh
RUN chsh -s /usr/bin/zsh $USER

# Use the "docker" user for subsequent setup (and when we connect)
USER $USER

# Tell zsh to load customisations (if they exist)
RUN echo '# Load customisations (if they exist)' >> $PROFILE_FILE
RUN echo '[ -f ~/.custom_bash_zsh ] && source ~/.custom_bash_zsh' >> $PROFILE_FILE

# Install zim for zsh
RUN curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# Install rbenv
ENV RBENV_ROOT /home/$USER/.rbenv
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT
RUN cd $RBENV_ROOT && src/configure && make -C src
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $PROFILE_FILE
RUN echo 'eval "$(rbenv init -)"' >> $PROFILE_FILE

# Install ruby-build
RUN mkdir -p $RBENV_ROOT/plugins
RUN git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build

# Enable rbenv in this session so that we can install latest Ruby as global
ENV PATH "$HOME_PATH/.rbenv/bin:$PATH"
RUN echo $PATH
RUN eval "$(rbenv init -)"
RUN rbenv version

# Install latest stable version of Ruby and set as global
RUN echo "Installing Ruby $(rbenv install --list-all | grep -v - | tail -1)"
RUN rbenv install $(rbenv install --list-all | grep -v - | tail -1)
RUN rbenv rehash
RUN rbenv global $(rbenv install --list-all | grep -v - | tail -1)

# Install nvm - see https://github.com/nvm-sh/nvm#installing-and-updating
# Once this is setup you should be able to install whichever version of Node you require
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash

# Setup PostgreSQL Apt Repository - see https://www.postgresql.org/download/linux/ubuntu/
# Once this setup you should be able to install whichever version of Postgres you require 
# Create the file repository configuration:
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# Import the repository signing key:
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# Update the package lists:
RUN sudo apt-get update

# Set ZIM_HOME at the start of .zshrc
RUN sed -i '1iexport ZIM_HOME=$HOME/.zim' $PROFILE_FILE

WORKDIR $HOME_PATH

# Keep the container running indefinitely once started
CMD ["tail", "-f", "/dev/null"]

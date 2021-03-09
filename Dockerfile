FROM debian:buster

ARG RUNNER_VERSION="2.277.1"

ENV GITHUB_PERSONAL_TOKEN ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV AGENT_TOOLSDIRECTORY "/home/github/_work/_tool"

RUN apt-get update && \
    apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        tar \
        wget \
        gnupg2 \
        apt-transport-https \
        ca-certificates \
        lsb-release \
        software-properties-common \
        build-essential zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libsqlite3-dev \
        libreadline-dev \
        libffi-dev curl \
        libbz2-dev \
    && apt-get clean all
    
RUN echo "DISTRIB_ID=$(lsb_release -si)" > /etc/lsb-release && \
    echo "DISTRIB_RELEASE=$(lsb_release -sr)" >> /etc/lsb-release && \
    echo "DISTRIB_CODENAME=$(lsb_release -sc)" >> /etc/lsb-release && \
    echo "DISTRIB_DESCRIPTION=\"$(lsb_release -sd)\"" >> /etc/lsb-release

RUN curl -O https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tar.xz && \
    tar -xf Python-3.8.8.tar.xz && cd Python-3.8.8 && \
    ./configure --enable-optimizations && \
    make && \
    make install

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt-get update && \
    apt-get install -y \
        php5.6 \
        php7.0 \
        php7.1 \
        php7.2 \
        php7.3 \
        php7.4 \
        php8.0 \
    && apt-get clean all\
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m github && \
    usermod -aG sudo github && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# setup docker runner
RUN curl -sSL https://get.docker.com/ | sh
RUN usermod -aG docker github

USER github
WORKDIR /home/github

RUN curl -O -L curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT [ "/home/github/entrypoint.sh" ]

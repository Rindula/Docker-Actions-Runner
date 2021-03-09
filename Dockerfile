FROM ubuntu:18.10

ARG RUNNER_VERSION="2.277.1"

ENV GITHUB_PERSONAL_TOKEN ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV AGENT_TOOLSDIRECTORY "/home/github/_work/_tool"
ENV DEBIAN_FRONTEND "NONINTERACTIVE"
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
        sshpass \
    && apt-get clean all
    
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
        php    php-pear \
        php5.6 php5.6-pear \
        php7.0 php7.0-pear \
        php7.1 php7.1-pear \
        php7.2 php7.2-pear \
        php7.3 php7.3-pear \
        php7.4 php7.4-pear \
        php8.0 php8.0-pear

RUN useradd -m github && \
    usermod -aG sudo github && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# setup docker runner
RUN curl -sSL https://get.docker.com/ | sh
RUN usermod -aG docker github

USER github
WORKDIR /home/github

RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT [ "/home/github/entrypoint.sh" ]

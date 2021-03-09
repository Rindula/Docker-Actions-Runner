FROM ubuntu:buster

ARG RUNNER_VERSION="2.277.1"

ENV GITHUB_PERSONAL_TOKEN ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV AGENT_TOOLSDIRECTORY "/home/github/_work/_tool"
ENV DEBIAN_FRONTEND "NONINTERACTIVE"

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
    && apt-get clean all
    
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

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

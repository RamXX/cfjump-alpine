FROM gliderlabs/alpine
MAINTAINER Ramiro Salas <rsalas@pivotal.io>

ENV ENAML /opt/enaml
ENV GOPATH /opt/go
ENV GOBIN /opt/go/bin
ENV OMGBIN /usr/local/bin
ENV PATH $GOBIN:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:/opt/google-cloud-sdk/bin
ENV HOME /root

ADD update_enaml.sh /usr/local/bin

RUN mkdir -p $ENAML
VOLUME $HOME
WORKDIR $HOME
RUN mkdir -p $HOME/bin

RUN echo "http://alpine.gliderlabs.com/alpine/edge/main" > /etc/apk/repositories
RUN echo "http://alpine.gliderlabs.com/alpine/edge/testing" >> /etc/apk/repositories
RUN echo "http://alpine.gliderlabs.com/alpine/v3.4/main" >> /etc/apk/repositories
RUN echo "http://alpine.gliderlabs.com/alpine/v3.4/community" >> /etc/apk/repositories
RUN apk update && apk upgrade
RUN apk-install bash go bzr git mercurial subversion openssh-client \
    ca-certificates wget curl jq ruby nodejs python2 iperf screen tmux \
    file tcpdump py-pip libcrypto1.0 ruby-dev ruby-bundler nmap perl \
    drill iproute2 iputils git-bash-completion bash-completion build-base \
    python2-dev linux-headers

# BOSH-related tools
# BOSH CLI
RUN gem install bosh_cli --no-ri --no-rdoc

# uaac CLI
RUN gem install cf-uaac --no-rdoc --no-ri

# Installs the new Golang BOSH CLI (alpha)
RUN go get -u github.com/cloudfoundry/bosh-cli

# Builds and installs bosh-init
RUN go get -u github.com/cloudfoundry/bosh-init

# bosh-bootloader
RUN curl -L "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v1.0.0/bbl-v1.0.0_linux_x86-64" > /usr/local/bin/bbl && chmod +x /usr/local/bin/bbl

# Spiff
RUN cd /usr/local/bin && wget -q -O spiff \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/spiff/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spiff

# Spruce
RUN cd /usr/local/bin && wget -q -O spruce \
    "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spruce

# Cloud Foundry utilities

# cf CLI
RUN curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.22.1&source=github-rel" | tar -C /usr/local/bin -zx

# Concourse fly CLI
RUN go get -u github.com/concourse/fly

# deployadactyl
RUN go get -u github.com/compozed/deployadactyl

# ASG Creator
RUN cd /usr/local/bin && wget -q -O asg-creator \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/asg-creator/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x asg-creator

# Pivotal-specific tools

# cf-mgmt CLI
RUN go get github.com/pivotalservices/cf-mgmt

# PivNet CLI
RUN wget -q -O /usr/local/bin/pivnet \
    "$(curl -s https://api.github.com/repos/pivotal-cf/pivnet-cli/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && \
    chmod +x /usr/local/bin/pivnet

# CFops
RUN wget -q -O /usr/local/bin/cfops \
    "$(curl -s https://api.github.com/repos/pivotalservices/cfops/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && \
    chmod +x /usr/local/bin/cfops

# OpsMan CLI
RUN cd /tmp && wget -q -O opsman.tgz \
    "$(curl -s https://api.github.com/repos/datianshi/opsman/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep tgz)" && tar xzf opsman.tgz && mv out/linux/opsman-cli /usr/local/bin \
    && chmod +x /usr/local/bin/opsman-cli

# Enaml-related tools

# Hashicorp's Vault
RUN wget $(wget -O- -q https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}') -O vault.zip && \
    unzip vault.zip && \
    mv vault /usr/local/bin/vault && \
    chmod 755 /usr/local/bin/vault && \
    rm vault.zip

# IaaS tools

# OpenStack CLI
RUN pip install python-openstackclient

# AWS CLI
RUN pip install awscli

# Azure CLI
RUN npm install -g azure-cli


# Google Compute
RUN curl -L "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-130.0.0-linux-x86_64.tar.gz" | tar -C /opt -zx && /opt/google-cloud-sdk/install.sh -q

# Other tools

# Hashicorp's Terraform
RUN curl -o terraform.zip \
    "https://releases.hashicorp.com/terraform/0.7.6/terraform_0.7.6_linux_amd64.zip" \
    && unzip terraform.zip && rm -f terraform.zip && mv terraform /usr/local/bin

# Square's Certstrap
RUN go get -u github.com/square/certstrap

# Safe CLI
RUN go get -u github.com/starkandwayne/safe

# Genesys
RUN curl "https://raw.githubusercontent.com/starkandwayne/genesis/master/bin/genesis" > /usr/local/bin/genesis \
    && chmod 0755 /usr/local/bin/genesis

# s3cmd
RUN pip install s3cmd

# Cleanup
RUN rm -rf $GOPATH/src $GOPATH/pkg
RUN rm -rf /tmp/*
RUN apk del ruby-dev ruby-bundler build-base python2-dev linux-headers libcrypto1.0

CMD ["/bin/bash"]

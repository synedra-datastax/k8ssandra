FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y apt-transport-https gnupg2 curl wget git docker sudo systemd
RUN curl -L0 "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" --output kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
RUN install -o root -g root -m 0755 kind /usr/local/bin/kind
RUN wget https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz
RUN tar -xzvf helm-v3.4.1-linux-amd64.tar.gz
RUN install -o root -g root -m 0755 linux-amd64/helm /usr/local/bin/helm
RUN git clone https://github.com/datastaxdevs/k8ssandra-workshop
RUN pwd
WORKDIR "./k8ssandra-workshop"
RUN helm repo add k8ssandra https://helm.k8ssandra.io/stable
RUN helm repo update
RUN helm repo add traefik https://helm.traefik.io/traefik
RUN helm repo update
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN apt-get update && apt-get install -y lsb-release && apt-get clean all
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]

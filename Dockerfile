FROM registry.tanzu.vmware.com/tanzu-application-platform/tap-packages@sha256:681ef8d2e6fc8414b3783e4de424adbfabf2aa0126e34fa7dcd07dab61e55a89

# All the direct Downloads need to run as root as they are going to /usr/local/bin
USER root
# TBS
RUN curl -L -o /usr/local/bin/kp https://github.com/vmware-tanzu/kpack-cli/releases/download/v0.4.2/kp-linux-0.4.2 && \
  chmod 755 /usr/local/bin/kp
# Tanzu CLI
COPY tanzu-framework-linux-amd64.tar /tmp
RUN export TANZU_CLI_NO_INIT=true
RUN cd /tmp && tar -xvf "tanzu-framework-linux-amd64.tar" -C /tmp && \ 
    sudo install "cli/core/v0.10.0/tanzu-core-linux_amd64" /usr/local/bin/tanzu && \ 
    tanzu plugin install --local cli all
# Knative
RUN curl -L -o /usr/local/bin/kn https://github.com/knative/client/releases/download/knative-v1.1.0/kn-linux-amd64 && \
    chmod 755 /usr/local/bin/kn

# Utilities
RUN apt-get update && apt-get install -y unzip

# kubectl krew
RUN \
( \
  set -x; cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew \
)
RUN echo "export PATH=\"${KREW_ROOT:-$HOME/.krew}/bin:$PATH\"" >> ${HOME}/.bashrc
ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
RUN kubectl krew install tree
RUN kubectl krew install view-secret
RUN kubectl krew install ctx
RUN kubectl krew install ns
RUN kubectl krew install eksporter
RUN kubectl krew install slice
RUN chmod 775 -R $HOME/.krew
RUN rm -rf /tmp/*

RUN apt update
RUN apt install ruby-full -y

USER 1001
COPY --chown=1001:0 . /home/eduk8s/
RUN fix-permissions /home/eduk8s
RUN rm /home/eduk8s/tanzu-framework-linux-amd64.tar

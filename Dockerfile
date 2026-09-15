FROM debian:13-slim
ARG TARGETPLATFORM
RUN apt update && apt install python3-pip python3 pipx git curl zsh dialog jq yq fzf eza nano neovim locales gettext-base apt-transport-https ca-certificates curl gnupg -y
COPY locale.gen /etc/locale.gen
RUN locale-gen
RUN pipx install pre-commit
RUN pipx install --include-deps ansible
RUN pipx inject ansible pytz pynetbox netaddr infisicalsdk passlib mitogen hvac 

# Teleport
RUN curl https://apt.releases.teleport.dev/gpg -o /usr/share/keyrings/teleport-archive-keyring.asc
RUN echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
https://apt.releases.teleport.dev/debian buster stable/v18" \
| tee /etc/apt/sources.list.d/teleport.list > /dev/null
RUN apt-get update && apt-get install teleport

# OpenTofu
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh && \
  chmod +x /tmp/install-opentofu.sh && /tmp/install-opentofu.sh --install-method deb && rm /tmp/install-opentofu.sh

# Sops
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    echo "Performing actions specific to AMD64"; \
    curl -LO https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64 && mv sops-v3.13.3.linux.amd64 /usr/bin/sops && chmod +x /usr/bin/sops; \
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    echo "Performing actions specific to ARM64"; \
    curl -LO https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.arm64 && mv sops-v3.13.3.linux.arm64 /usr/bin/sops && chmod +x /usr/bin/sops; \
    else \
    echo "Unknown platform" && exit 1; \
fi

# OpenBao
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    echo "Performing actions specific to AMD64"; \
    curl -fsSLo /tmp/openbao.tar.gz https://github.com/openbao/openbao/releases/download/v2.6.2/openbao_2.6.2_linux_amd64.tar.gz && tar -xzf /tmp/openbao.tar.gz -C /usr/bin bao && ln -s /usr/bin/bao /usr/bin/openbao && rm /tmp/openbao.tar.gz; \
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    echo "Performing actions specific to ARM64"; \
    curl -fsSLo /tmp/openbao.tar.gz https://github.com/openbao/openbao/releases/download/v2.6.2/openbao_2.6.2_linux_arm64.tar.gz && tar -xzf /tmp/openbao.tar.gz -C /usr/bin bao && ln -s /usr/bin/bao /usr/bin/openbao && rm /tmp/openbao.tar.gz; \
else \
    echo "Unknown platform" && exit 1; \
fi

# Helm

RUN curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x /tmp/get_helm.sh && /tmp/get_helm.sh && rm /tmp/get_helm.sh

# OhMyZsh
RUN /bin/zsh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
RUN git clone https://github.com/Aloxaf/fzf-tab /root/.oh-my-zsh/custom/plugins/fzf-tab
RUN /bin/zsh -c '/root/.local/bin/ansible-galaxy collection install infisical.vault netbox.netbox'


COPY .zshrc /root/.zshrc

CMD ["/bin/bash"]

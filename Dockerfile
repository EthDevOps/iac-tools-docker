FROM debian:12-slim
ARG TARGETPLATFORM
RUN apt update && apt install python3-pip python3 pipx git curl zsh dialog jq yq fzf exa neovim locales gettext-base -y
COPY locale.gen /etc/locale.gen
RUN locale-gen
RUN pipx install pre-commit
RUN pipx install --include-deps ansible
RUN pipx inject ansible pytz pynetbox infisical-python netaddr infisicalsdk

# Teleport
RUN curl https://apt.releases.teleport.dev/gpg -o /usr/share/keyrings/teleport-archive-keyring.asc
RUN echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
https://apt.releases.teleport.dev/debian buster stable/v16" \
| tee /etc/apt/sources.list.d/teleport.list > /dev/null
RUN apt-get update && apt-get install teleport

# OpenTofu
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh && \
  chmod +x /tmp/install-opentofu.sh && /tmp/install-opentofu.sh --install-method deb

# Sops
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        echo "Performing actions specific to AMD64"; \
        curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64 && mv sops-v3.9.0.linux.amd64 /usr/bin/sops && chmod +x /usr/bin/sops; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        echo "Performing actions specific to ARM64"; \
        curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.arm64 && mv sops-v3.9.0.linux.arm64 /usr/bin/sops && chmod +x /usr/bin/sops; \
    else \
        echo "Unknown platform"; \
    fi

# Helm

RUN curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x /tmp/get_helm.sh && /tmp/get_helm.sh

# OhMyZsh
RUN /bin/zsh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
RUN git clone https://github.com/Aloxaf/fzf-tab /root/.oh-my-zsh/custom/plugins/fzf-tab
RUN /bin/zsh -c '/root/.local/bin/ansible-galaxy collection install infisical.vault'


COPY .zshrc /root/.zshrc

CMD ["/bin/bash"]

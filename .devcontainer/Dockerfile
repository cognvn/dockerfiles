FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# download cloudflared tunnel
USER root
RUN curl -o /usr/local/bin/cloudflared -sSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64; \
    chmod +x /usr/local/bin/cloudflared

USER vscode
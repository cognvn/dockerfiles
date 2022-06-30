FROM mcr.microsoft.com/vscode/devcontainers/universal:dev

# download cloudflared tunnel
USER root
RUN curl -o /usr/local/bin/cloudflared -sSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64; \
    chmod +x /usr/local/bin/cloudflared

USER codespace
FROM mcr.microsoft.com/vscode/devcontainers/universal:dev

# download cloudflared tunnel
RUN curl -sS -o /usr/local/bin/cloudflared -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64; \
    chmod +x /usr/local/bin/cloudflared
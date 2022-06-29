FROM debian:bullseye-slim

RUN export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get upgrade -y; \
	apt-get install -y curl gnupg; \
	rm -rf /var/lib/apt/lists/*

ARG APP_VERSION=7.0.1
RUN curl -fsSL https://releases.mattermost.com/${APP_VERSION}/mattermost-${APP_VERSION}-linux-amd64.tar.gz | tar -xz -C /opt; \
	mkdir -p /opt/mattermost/data; \
	useradd --system --user-group mattermost; \
	chown -R mattermost:mattermost /opt/mattermost; \
	chmod -R g+w /opt/mattermost

USER mattermost
WORKDIR /opt/mattermost

ARG DATABASE_URL
ARG PGSSLMODE=disable
RUN /opt/mattermost/bin/mattermost db init --config $(echo $DATABASE_URL | sed -e "s/postgresql:/postgres:/")?sslmode=${PGSSLMODE}&connect_timeout=10

ENV PORT=8065
EXPOSE 8065
ENTRYPOINT ["/opt/mattermost/bin/mattermost"]

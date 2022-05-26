FROM opensearchproject/opensearch:latest

COPY --chown=opensearch:opensearch opensearch.yml /usr/share/opensearch/config/opensearch.yml
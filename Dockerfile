FROM oaklight/llm-rosetta-gateway:latest

WORKDIR /app

COPY config.jsonc.example /defaults/config.jsonc
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p /config

EXPOSE 8765

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

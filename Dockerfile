# Limelit Open on Railway: the official image (pinned by digest) behind Caddy basic auth.
# Upstream's dashboard has no login (it is meant for localhost), so on a public Railway
# domain Caddy asks for LIMELIT_USERNAME / LIMELIT_PASSWORD on every page. /mcp keeps
# upstream's own bearer-token auth and /healthz stays open for Railway's healthcheck.
FROM caddy:2.11.7-alpine@sha256:e70b164da81ef698b3ad19af799ea6086ce6d9e48ed4079eb9fe26f6fbf14ee5 AS caddy

FROM ghcr.io/limelit-co/open:0.1.0-rc.14@sha256:bf2ddbbe0070c5cb54a5ca1f34d2a217fc4efde03b01bcafa3f05eb6b949738c
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/limelit-open" \
      org.opencontainers.image.licenses="Apache-2.0"
USER root
RUN apk add --no-cache su-exec
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY railway/Caddyfile /etc/caddy/Caddyfile
COPY --chmod=755 railway/railway-start.sh /usr/local/bin/railway-start
ENV PORT=1515 \
    LIMELIT_DATA_DIR=/data \
    LIMELIT_USERNAME=admin \
    XDG_CONFIG_HOME=/tmp/caddy-config \
    XDG_DATA_HOME=/tmp/caddy-data
ENTRYPOINT ["/usr/local/bin/railway-start"]

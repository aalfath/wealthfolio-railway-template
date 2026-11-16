# Wealthfolio for Railway: the official image, pinned by version and digest,
# plus a small entrypoint that turns a generated password into the Argon2id
# hash Wealthfolio expects.
FROM wealthfolio/wealthfolio:3.13.0@sha256:6600feaa06910a35854bc07a4cdf943a29b4a7a443190912e3d3c02288533ed2

USER root
RUN apk add --no-cache argon2 su-exec

# Fixed settings. Deployers can still override any of them with a variable.
ENV WF_DB_PATH=/data/wealthfolio.db \
    WF_COOKIE_SECURE=auto \
    WF_MCP_ENABLED=false \
    WF_AUTH_TOKEN_TTL_MINUTES=60 \
    WF_REQUEST_TIMEOUT_MS=30000

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-entrypoint.sh

EXPOSE 8088
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/usr/local/bin/wealthfolio-server"]

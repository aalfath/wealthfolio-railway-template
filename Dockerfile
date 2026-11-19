# Wealthfolio for Railway: the official image, pinned by version and digest,
# plus a small entrypoint that turns a generated password into the Argon2id
# hash Wealthfolio expects.
FROM wealthfolio/wealthfolio:3.13.1@sha256:a51bf08440ec3c517b728e4d5a7d9134cc564e1749eec45bd4f0b7f39573336e

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

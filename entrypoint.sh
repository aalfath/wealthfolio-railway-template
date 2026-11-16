#!/bin/sh
# Railway wrapper for Wealthfolio.
# - Listens on $PORT (default 8088).
# - Makes the /data volume writable for the unprivileged wealthfolio user
#   (Railway mounts volumes as root) and then drops privileges.
# - If WF_AUTH_PASSWORD_HASH is not set, hashes WF_ADMIN_PASSWORD with
#   Argon2id once and caches the hash on the volume. Change WF_ADMIN_PASSWORD
#   and redeploy to change the login password.
set -eu

DATA_DIR=$(dirname "${WF_DB_PATH:-/data/wealthfolio.db}")
mkdir -p "$DATA_DIR"
chown -R wealthfolio:wealthfolio "$DATA_DIR" 2>/dev/null || true

export WF_LISTEN_ADDR="${WF_LISTEN_ADDR:-0.0.0.0:${PORT:-8088}}"

if [ -z "${WF_AUTH_PASSWORD_HASH:-}" ]; then
  pw="${WF_ADMIN_PASSWORD:-}"
  if [ "${#pw}" -lt 12 ]; then
    echo "railway-entrypoint: set WF_ADMIN_PASSWORD (12 or more characters) or WF_AUTH_PASSWORD_HASH (an \$argon2id\$ hash)" >&2
    exit 1
  fi
  cache="$DATA_DIR/.wf-auth"
  key=$(printf '%s' "$pw" | sha256sum | cut -c1-64)
  if [ -f "$cache" ] && [ "$(sed -n 1p "$cache")" = "$key" ]; then
    hash=$(sed -n 2p "$cache")
  else
    salt=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 16)
    hash=$(printf '%s' "$pw" | argon2 "$salt" -id -t 3 -m 16 -p 1 -e)
    umask 077
    printf '%s\n%s\n' "$key" "$hash" > "$cache"
    chown wealthfolio:wealthfolio "$cache"
    echo "railway-entrypoint: login password hashed and cached in $cache"
  fi
  export WF_AUTH_PASSWORD_HASH="$hash"
else
  case "$WF_AUTH_PASSWORD_HASH" in
    '$argon2id$'*) ;;
    *) echo "railway-entrypoint: WF_AUTH_PASSWORD_HASH must be an Argon2id PHC string starting with \$argon2id\$; leave it empty to use WF_ADMIN_PASSWORD" >&2; exit 1 ;;
  esac
fi
unset WF_ADMIN_PASSWORD

exec su-exec wealthfolio:wealthfolio "$@"

# Wealthfolio on Railway

This repo packages [Wealthfolio](https://github.com/wealthfolio/wealthfolio) (a private, local-first tracker for investments, net worth and spending) for one-click deploys on Railway.

## What the template deploys

- One service built from this repo's `Dockerfile`: the official image `wealthfolio/wealthfolio:3.13.0`, pinned by digest, plus a small entrypoint.
- One volume at `/data` for the SQLite profile databases, the encrypted secrets vault and add-ons.
- A Railway domain, with the health check on `/api/v1/healthz`.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `WF_ADMIN_PASSWORD` | generated (`secret(24)`) | Your login password. Find it in the service's Variables tab. Change it and redeploy to change the password. |
| `WF_SECRET_KEY` | generated | Encrypts stored secrets and signs sessions. Keep it stable: changing it makes stored secrets unreadable. |
| `WF_CORS_ALLOW_ORIGINS` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | The browser origin allowed to call the API. Add your custom domain here if you attach one. |
| `PORT` | `8088` | The port Wealthfolio listens on and Railway routes to. |

The template asks you nothing at deploy time.

**Optional:** set `WF_AUTH_PASSWORD_HASH` to your own Argon2id hash (a string starting with `$argon2id$`) to use it instead of `WF_ADMIN_PASSWORD`. Any other value stops the service with a clear error. OIDC single sign-on (`WF_OIDC_*`) works as described in the [upstream README](https://github.com/wealthfolio/wealthfolio/blob/v3.13.0/README.md#authentication-web-mode).

## How the entrypoint works

1. Binds Wealthfolio to `0.0.0.0:$PORT`.
2. Railway mounts volumes as root, so it gives `/data` to the image's `wealthfolio` user and then runs the server as that user (`su-exec`).
3. If `WF_AUTH_PASSWORD_HASH` is empty, it hashes `WF_ADMIN_PASSWORD` with Argon2id once and caches the hash in `/data/.wf-auth` (keyed by the password's SHA-256), so later restarts reuse it.

Fixed settings are baked into the image as defaults: `WF_DB_PATH=/data/wealthfolio.db`, `WF_COOKIE_SECURE=auto`, `WF_MCP_ENABLED=false`, `WF_AUTH_TOKEN_TTL_MINUTES=60`, `WF_REQUEST_TIMEOUT_MS=30000`. Any of them can be overridden with a service variable.

## Updates

New Wealthfolio releases land here as a pinned version bump with an entry in [CHANGELOG.md](CHANGELOG.md). When this repo's `main` changes, Railway shows deployers an "update available" notice, and they choose when to apply it. Read the changelog first. Back up the `/data` volume before a major version update.

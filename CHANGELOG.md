# Changelog

## 3.13.0-railway.1 (2026-11-16)

**Breaking for anyone moving from the old image-based template:** the login no longer needs a pasted Argon2id hash. The template now generates `WF_ADMIN_PASSWORD` and hashes it at start. If you keep `WF_AUTH_PASSWORD_HASH`, it must start with `$argon2id$`.

- First release of the repo-based template, replacing the image-only `wealthfolio` template (Wealthfolio 3.6.2).
- Wealthfolio 3.13.0, `wealthfolio/wealthfolio:3.13.0@sha256:6600feaa06910a35854bc07a4cdf943a29b4a7a443190912e3d3c02288533ed2`.
- Fixes failed deploys: a plain password typed into the old `WF_AUTH_PASSWORD_HASH` prompt made the server exit at start, so the health check never passed.
- Runs the server as the image's unprivileged `wealthfolio` user; no `RAILWAY_RUN_UID=0` needed.
- Listens on `$PORT` (default 8088).

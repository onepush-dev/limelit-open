# Limelit Open on Railway

One-click Railway template for [Limelit Open](https://github.com/limelit-co/open) 0.1.0-rc.14 (Apache-2.0): self-hosted AI-visibility tracking. It asks ChatGPT, Claude, Perplexity, Gemini and Google AI Overviews your category's prompts and shows how often they mention and cite your brand against competitors, with a built-in MCP server.

Deploy button: added after the template is generated.

## What this repo adds

The image `ghcr.io/onepush-dev/limelit-open:0.1.0-rc.14` is `ghcr.io/limelit-co/open:0.1.0-rc.14` (pinned by digest) plus Caddy 2.11.7:

- Upstream's dashboard has **no login** (it is built for `localhost`). On a public Railway domain anyone could read your data, change settings or spend your provider keys, so Caddy puts HTTP basic auth (`LIMELIT_USERNAME` / `LIMELIT_PASSWORD`) in front of every page.
- `/mcp` is passed through untouched: it has upstream's own bearer-token auth (generate the token in Settings, or set `LIMELIT_MCP_TOKEN`) and refuses everything until a token exists. `/healthz` stays open for Railway's healthcheck.
- `railway/railway-start.sh` fixes ownership of the Railway volume at `/data`, then runs limelit on `127.0.0.1:1516` and Caddy on `$PORT` (8080), both as the unprivileged `limelit` user. `LIMELIT_SCHEDULE` / `LIMELIT_RUNS_PER_DAY` work as in upstream's entrypoint. Litestream is not used (the volume keeps the SQLite database).

## Template variables

| Variable | Value |
| --- | --- |
| `LIMELIT_PASSWORD` | `${{secret(24)}}` (dashboard basic-auth password; username `admin`) |
| `LIMELIT_SECRET` | `${{secret(48)}}` (encrypts provider keys pasted into the dashboard) |

Optional: `LIMELIT_USERNAME` (default `admin`), `LIMELIT_SCHEDULE` (`daily`, `hourly`, `off`), `LIMELIT_RUNS_PER_DAY` (default 200), `LIMELIT_MCP_TOKEN`, provider keys `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `PERPLEXITY_API_KEY`, `GOOGLE_API_KEY`, `OPENROUTER_API_KEY`, `DATAFORSEO_LOGIN`/`DATAFORSEO_PASSWORD` and the others listed upstream.

## After deploy

Open the public URL, sign in with `admin` and `LIMELIT_PASSWORD` from the service Variables, and follow the setup wizard: your domain, competitors, a starter prompt pack, and one key (a free Limelit key from limelit.co, or your own OpenAI key). Each tracked prompt costs API calls on your own provider account.

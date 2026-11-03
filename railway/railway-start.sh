#!/bin/sh
# Railway start wrapper for Limelit Open: fixes /data ownership on the volume, starts
# limelit on 127.0.0.1:1516 and Caddy (basic auth) on $PORT, both as the limelit user.
set -eu
mkdir -p /data
[ "$(stat -c %u /data)" = 10001 ] || chown -R limelit:limelit /data
if [ -z "${LIMELIT_PASSWORD:-}" ]; then
  echo "railway-start: LIMELIT_PASSWORD is required (the dashboard has no login of its own)" >&2
  exit 1
fi
LIMELIT_PASSWORD_HASH=$(caddy hash-password --plaintext "$LIMELIT_PASSWORD")
export LIMELIT_PASSWORD_HASH
unset LIMELIT_PASSWORD
CFG=""
if [ -n "${LIMELIT_SCHEDULE:-}" ]; then
  printf 'schedule: %s\nlimits:\n  runs_per_day: %s\n' \
    "$LIMELIT_SCHEDULE" "${LIMELIT_RUNS_PER_DAY:-200}" > /tmp/limelit.yaml
  chown limelit /tmp/limelit.yaml
  CFG="--config /tmp/limelit.yaml"
fi
cd /data
su-exec limelit limelit serve --addr 127.0.0.1:1516 $CFG &
app=$!
su-exec limelit caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
proxy=$!
trap 'kill -TERM $app $proxy 2>/dev/null' TERM INT
# Exit (so Railway restarts the container) as soon as either process stops.
while kill -0 $app 2>/dev/null && kill -0 $proxy 2>/dev/null; do sleep 2; done
kill -TERM $app $proxy 2>/dev/null || true
wait $app 2>/dev/null; wait $proxy 2>/dev/null
exit 1

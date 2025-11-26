#!/usr/bin/env bash
set -e

# ---------- CONFIG FROM ENV ----------

# Required: TAILSCALE_AUTHKEY must be passed in env
if [ -z "${TAILSCALE_AUTHKEY}" ]; then
  echo "ERROR: TAILSCALE_AUTHKEY is not set"
  echo "Go to Render → your service → Environment → add TAILSCALE_AUTHKEY"
  exit 1
fi

# Optional hostname (what shows in Tailscale admin)
: "${TAILSCALE_HOSTNAME:=render-tailscale}"

# Render sets PORT (like 10000+). Default to 8080 for local testing.
: "${PORT:=8080}"

echo "Using hostname: ${TAILSCALE_HOSTNAME}"
echo "HTTP server will listen on PORT=${PORT}"

# ---------- START TAILSCALE (USERSPACE MODE) ----------

# Make state dir
mkdir -p /var/lib/tailscale

# Start tailscaled in userspace-networking mode
/usr/sbin/tailscaled \
  --state=/var/lib/tailscale/tailscaled.state \
  --tun=userspace-networking \
  --socks5-server=localhost:1055 \
  &

TS_PID=$!

# Wait a bit for daemon to be ready
sleep 5

# Bring Tailscale interface up
tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME}" \
  --accept-routes=true \
  --accept-dns=false \
  --netfilter-mode=off

echo "Tailscale is up."

# Optional: expose your HTTP server on the tailnet via 'tailscale serve'
# This makes your app reachable at:
#   https://${TAILSCALE_HOSTNAME}.tailnet-YOURDOMAIN.ts.net/
# (depends on your tailnet name)
tailscale serve https / "http://127.0.0.1:${PORT}" || \
  echo "tailscale serve not available (older Tailscale version?)"

echo "Starting HTTP server on port ${PORT}..."

# ---------- START YOUR APP (FOREGROUND) ----------

python3 -m http.server "${PORT}"

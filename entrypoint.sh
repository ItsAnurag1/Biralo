#!/usr/bin/env bash
set -e

# Required: TAILSCALE_AUTHKEY must be passed in env
if [ -z "${TAILSCALE_AUTHKEY}" ]; then
  echo "ERROR: TAILSCALE_AUTHKEY is not set"
  exit 1
fi

# Optional hostname
: "${TAILSCALE_HOSTNAME:=container-tailscale}"

# Start tailscaled (daemon)
# If your platform does NOT allow /dev/net/tun, use --tun=userspace-networking
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state &
TS_PID=$!

# Wait a bit for daemon to be ready
sleep 5

# Bring Tailscale interface up
tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME}" \
  --accept-routes=true \
  --accept-dns=true

echo "Tailscale is up. Starting HTTP server..."

# Start your app (keep this in foreground)
python3 -m http.server 8080

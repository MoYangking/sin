#!/bin/sh
set -eu

PORT="${PORT:-7860}"
WS_PATH="${WS_PATH:-/ws}"
UUID="${UUID:-}"
LOG_LEVEL="${LOG_LEVEL:-info}"

case "$WS_PATH" in
  /*) : ;;
  *) WS_PATH="/$WS_PATH" ;;
esac

if [ -z "$UUID" ]; then
  UUID="$(cat /proc/sys/kernel/random/uuid)"
  echo "UUID not set; generated UUID: $UUID" >&2
fi

mkdir -p /etc/sing-box /etc/caddy

cat > /etc/sing-box/config.json <<EOF
{
  "log": {
    "level": "${LOG_LEVEL}",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "vmess",
      "tag": "vmess-in",
      "listen": "127.0.0.1",
      "listen_port": 10000,
      "users": [
        {
          "uuid": "${UUID}",
          "alterId": 0
        }
      ],
      "transport": {
        "type": "ws",
        "path": "${WS_PATH}"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

cat > /etc/caddy/Caddyfile <<EOF
:${PORT} {
  @vmess path ${WS_PATH}
  handle @vmess {
    reverse_proxy 127.0.0.1:10000
  }
  handle {
    respond "OK" 200
  }
}
EOF

sing-box run -c /etc/sing-box/config.json &
sb_pid="$!"

/usr/local/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid="$!"

term() {
  kill "$sb_pid" "$caddy_pid" 2>/dev/null || true
}
trap term INT TERM

while :; do
  if ! kill -0 "$sb_pid" 2>/dev/null; then
    wait "$sb_pid"
    exit "$?"
  fi
  if ! kill -0 "$caddy_pid" 2>/dev/null; then
    wait "$caddy_pid"
    exit "$?"
  fi
  sleep 1
done


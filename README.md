---
title: sing-box-ws
sdk: docker
app_port: 7860
---

This Docker Space exposes a `VMess + WebSocket` inbound via Hugging Face's single HTTPS entrypoint.

Note: sing-box's `shadowsocks` inbound is plain TCP/UDP only (no WebSocket transport), so a “Shadowsocks-over-HTTPS” setup
would require a different Shadowsocks server + plugin. On Spaces, `VMess + WS` fits the “single HTTPS port” constraint
without extra plugins.

## Environment variables

- `UUID` (recommended): VMess user UUID (if unset, the container prints a generated UUID to logs on startup)
- `WS_PATH` (optional): WebSocket path, default `/ws`
- `LOG_LEVEL` (optional): sing-box log level, default `info`
- `PORT` (optional): container listen port, default `7860` (HF Spaces uses this)

## Clash example

Fill `server` with your Space domain like `xxxxxx.hf.space`.

```yaml
proxies:
  - name: hf-vmess-ws
    type: vmess
    server: xxxxxx.hf.space
    port: 443
    uuid: YOUR_UUID
    alterId: 0
    cipher: auto
    tls: true
    network: ws
    ws-opts:
      path: /ws
      headers:
        Host: xxxxxx.hf.space
```

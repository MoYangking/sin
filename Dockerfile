FROM debian:bookworm-slim

ARG SING_BOX_VERSION=1.12.14
ARG CADDY_VERSION=2.10.2

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl tar gzip \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) sb_arch="amd64"; caddy_arch="amd64" ;; \
    arm64) sb_arch="arm64"; caddy_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${sb_arch}.tar.gz"; \
  tar -C /tmp -xzf /tmp/sing-box.tar.gz; \
  install -m 0755 "/tmp/sing-box-${SING_BOX_VERSION}-linux-${sb_arch}/sing-box" /usr/local/bin/sing-box; \
  rm -rf /tmp/sing-box*; \
  curl -fsSL -o /tmp/caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_${caddy_arch}.tar.gz"; \
  tar -C /usr/local/bin -xzf /tmp/caddy.tar.gz caddy; \
  chmod 0755 /usr/local/bin/caddy; \
  rm -f /tmp/caddy.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

ENV PORT=7860
EXPOSE 7860

CMD ["/entrypoint.sh"]


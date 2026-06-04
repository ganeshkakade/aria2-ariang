#!/bin/sh

CONFIG_PATH=/aria2/config
DEFAULT_CONFIG_PATH=/aria2/default_config
DOWNLOADS_PATH=/aria2/downloads

if [ ! -f "$CONFIG_PATH/aria2.conf" ]; then
  cp "$DEFAULT_CONFIG_PATH/aria2.conf" "$CONFIG_PATH/aria2.conf"
fi

if [ -n "$RPC_SECRET" ]; then
  sed -i '/^rpc-secret=/d' "$CONFIG_PATH/aria2.conf"
  printf 'rpc-secret=%s\n' "${RPC_SECRET}" >> "$CONFIG_PATH/aria2.conf"
fi

if [ -n "$BASIC_AUTH_USERNAME" ] && [ -n "$BASIC_AUTH_PASSWORD" ]; then
  echo "
    basicauth / {
      $BASIC_AUTH_USERNAME $(caddy hash-password --plaintext "${BASIC_AUTH_PASSWORD}")
    }
  " >> /etc/caddy/Caddyfile
fi

touch "$CONFIG_PATH/aria2.session"

userid="$(id -u)"
groupid="$(id -g)"

if [ -n "$PUID" ] && [ -n "$PGID" ]; then
  userid=$PUID
  groupid=$PGID
fi

chown -R "$userid:$groupid" "$CONFIG_PATH"
chown -R "$userid:$groupid" "$DOWNLOADS_PATH"

caddy start --config /etc/caddy/Caddyfile
exec su-exec "$userid:$groupid" aria2c --conf-path="$CONFIG_PATH/aria2.conf"

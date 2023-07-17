#!/bin/sh

config_path=/aria2/config
default_config_path=/aria2/default-config
downloads_path=/aria2/downloads

if [ ! -f $config_path/aria2.conf ]; then
  cp $default_config_path/aria2.conf $config_path/aria2.conf
fi

if [ -n "$RPC_SECRET" ]; then
  sed -i '/^rpc-secret=/d' $config_path/aria2.conf
  printf 'rpc-secret=%s\n' "${RPC_SECRET}" >> $config_path/aria2.conf
fi

if [ -n "$BASIC_AUTH_USERNAME" ] && [ -n "$BASIC_AUTH_PASSWORD" ]; then
  echo "
    basicauth / {
      $BASIC_AUTH_USERNAME $(caddy hash-password --plaintext "${BASIC_AUTH_PASSWORD}")
    }
  " >> /etc/caddy/Caddyfile
fi

touch $config_path/aria2.session

userid="$(id -u)"
groupid="$(id -g)"

if [[ -n "$PUID" && -n "$PGID" ]]; then
  userid=$PUID
  groupid=$PGID
fi

chown -R "$userid":"$groupid" $config_path
chown -R "$userid":"$groupid" $downloads_path

caddy start --config /etc/caddy/Caddyfile
su-exec "$userid":"$groupid" aria2c --conf-path=/aria2/config/aria2.conf

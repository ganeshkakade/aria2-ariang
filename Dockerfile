FROM alpine:3.20

RUN apk add --no-cache aria2 caddy su-exec curl jq \
  && ARIANG_VERSION=$(curl -s https://api.github.com/repos/mayswind/AriaNg/releases/latest | jq -r '.tag_name') \
  && wget --no-check-certificate "https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip" -O ariang.zip \
  && unzip ariang.zip -d ariang \
  && rm -rf ariang.zip

COPY Caddyfile /etc/caddy/Caddyfile
COPY default_config/aria2.conf /aria2/default_config/aria2.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME /aria2/config
VOLUME /aria2/downloads

EXPOSE 6800 8080

ENTRYPOINT ["sh", "/entrypoint.sh"]

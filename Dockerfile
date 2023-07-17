FROM alpine:3.18.0

RUN apk add --no-cache aria2 caddy su-exec \
  && wget --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/1.3.6/AriaNg-1.3.6.zip -O ariang.zip \
  && unzip ariang.zip -d ariang \
  && rm -rf ariang.zip

COPY Caddyfile /etc/caddy/Caddyfile
COPY default-config/aria2.conf /aria2/default-config/aria2.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME /aria2/config
VOLUME /aria2/downloads

EXPOSE 6800 8080

ENTRYPOINT ["sh", "/entrypoint.sh"]

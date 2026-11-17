# Eclipse Mosquitto MQTT broker for Railway: the official image plus a small
# Caddy router, so MQTT over WebSocket and the built-in dashboard share the
# one HTTPS domain Railway gives a service. Plain MQTT goes through a TCP proxy.
FROM caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b AS caddy

FROM eclipse-mosquitto:2.1.2-alpine@sha256:75d6662dee52c947dc9dd9c29f1d8d7ffef78ddaf38001caa09755681e8bbc98

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY mosquitto.conf /mosquitto/config/mosquitto.conf
COPY start.sh /usr/local/bin/railway-start.sh
RUN chmod 0755 /usr/local/bin/railway-start.sh

ENV PORT=8080
EXPOSE 8080 1883

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]

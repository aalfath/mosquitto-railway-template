# Changelog

Each entry is one version of this Railway template. Breaking changes come first.

## 2.1.2-1 (2026-11-17)

- First release: Eclipse Mosquitto 2.1.2 (`eclipse-mosquitto:2.1.2-alpine@sha256:75d6662dee52c947dc9dd9c29f1d8d7ffef78ddaf38001caa09755681e8bbc98`) and Caddy 2.11.9 (`caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b`).
- Login required on every listener (password file built from `MQTT_USERNAME`, `MQTT_PASSWORD` and optional `MQTT_EXTRA_USERS` on each start).
- Persistence on a volume at `/mosquitto/data`.
- Railway domain: dashboard at `/`, MQTT over WebSocket at `/mqtt`, health check at `/healthz`. TCP proxy on 1883 for plain MQTT.

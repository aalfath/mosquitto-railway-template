[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/eclipse-mosquitto?utm_medium=integration&utm_source=button&utm_campaign=mosquitto)

# Eclipse Mosquitto on Railway

A one-click [Railway](https://railway.com) template for [Eclipse Mosquitto](https://mosquitto.org/), the open-source MQTT broker.

## What it deploys

One service, `Mosquitto`, built from this repo's `Dockerfile`:

- **Mosquitto 2.1.2**, from the official image `eclipse-mosquitto:2.1.2-alpine`, pinned by digest.
- **Caddy 2.11.9** (official image, pinned by digest) in the same container, listening on Railway's `PORT` (8080):
  - `https://YOUR-DOMAIN/` is Mosquitto's built-in dashboard, behind the same login as MQTT.
  - `wss://YOUR-DOMAIN/mqtt` is MQTT over WebSocket (TLS from Railway).
  - `https://YOUR-DOMAIN/healthz` is the health check (no login, answers only when the broker is up).
- **A TCP proxy on port 1883** for plain MQTT from outside Railway.
- **A volume at `/mosquitto/data`**: retained messages, persistent sessions and queued QoS 1/2 messages survive restarts and redeploys (saved every 60 s and on shutdown).

Anonymous clients are refused on every listener.

## Variables

| Variable | Default | What it is |
|---|---|---|
| `MQTT_USERNAME` | `mqtt` | MQTT and dashboard user. |
| `MQTT_PASSWORD` | generated | Password of that user. |
| `MQTT_URL` | reference | `mqtt://user:password@mosquitto.railway.internal:1883`, for other services in the same project. |
| `MQTT_PUBLIC_URL` | reference | `mqtt://user:password@TCP-PROXY-HOST:PORT`, for clients outside Railway. |
| `PORT` | `8080` | Port Caddy listens on for the Railway domain. |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `15` | Time the broker gets on redeploy to save its data before the old container stops. |

Optional, not in the template (add it to the service if you need it):

- `MQTT_EXTRA_USERS`: more users as `user1:password1,user2:password2`.

The password file is rebuilt from these variables on every start, so changing a password means changing the variable and redeploying. The start script refuses to start when `MQTT_PASSWORD` is empty.

## Connecting

- From another Railway service in the same project: `${{Mosquitto.MQTT_URL}}`, or host `mosquitto.railway.internal`, port `1883` (IPv4 and IPv6).
- From outside, plain MQTT: `${{Mosquitto.MQTT_PUBLIC_URL}}` (host and port are also in the service's Settings → Networking). This is unencrypted TCP; use WebSocket below when the network isn't trusted.
- From outside, encrypted: `wss://YOUR-DOMAIN:443/mqtt`, for example `mosquitto_sub -L wss://mqtt:PASSWORD@YOUR-DOMAIN:443/mqtt -t '#'`.

## Updates

Mosquitto and Caddy are pinned by version and digest in the `Dockerfile`. When this repo's `main` branch gets a new version, Railway shows an "update available" notice to everyone who deployed the template, and each deployer chooses when to apply it. Read `CHANGELOG.md` before you update; breaking changes are listed first.

## License

Mosquitto is dual-licensed under EPL-2.0 and EDL-1.0 (BSD-3-Clause). This repo's wrapper files (Dockerfile, start script, Caddyfile, config) are MIT.

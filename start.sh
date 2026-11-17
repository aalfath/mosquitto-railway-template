#!/bin/sh
# Start script for the Eclipse Mosquitto Railway template.
# Writes the password file, then runs Mosquitto and Caddy side by side and
# stops the container when either exits, so Railway restarts it.
set -eu

export PORT="${PORT:-8080}"
MQTT_USERNAME="${MQTT_USERNAME:-mqtt}"
MQTT_PASSWORD="${MQTT_PASSWORD:-}"

if [ -z "$MQTT_PASSWORD" ]; then
	echo "MQTT_PASSWORD is empty: refusing to start a broker without a password." >&2
	exit 1
fi
case "$MQTT_USERNAME" in
	*:*) echo "MQTT_USERNAME must not contain ':'." >&2; exit 1 ;;
esac

# Railway mounts a fresh volume owned by root; the broker runs as mosquitto.
mkdir -p /mosquitto/data
chown -R mosquitto:mosquitto /mosquitto/data

# The password file is rebuilt on every boot, so changing MQTT_PASSWORD (or
# MQTT_EXTRA_USERS) and redeploying changes the logins.
PASSWD=/mosquitto/config/passwd
tmp="$(mktemp -d)"
umask 077
mosquitto_passwd -c -b "$tmp/passwd" "$MQTT_USERNAME" "$MQTT_PASSWORD" >/dev/null
# Optional: more users as "user1:pass1,user2:pass2".
if [ -n "${MQTT_EXTRA_USERS:-}" ]; then
	old_ifs="$IFS"; IFS=','
	for pair in $MQTT_EXTRA_USERS; do
		user="${pair%%:*}"; pass="${pair#*:}"
		if [ -z "$user" ] || [ "$user" = "$pair" ] || [ -z "$pass" ]; then
			echo "MQTT_EXTRA_USERS: skipping an entry that isn't user:password." >&2
			continue
		fi
		mosquitto_passwd -b "$tmp/passwd" "$user" "$pass" >/dev/null
	done
	IFS="$old_ifs"
fi
chown mosquitto:mosquitto "$tmp/passwd"
mv -f "$tmp/passwd" "$PASSWD"
rmdir "$tmp"
umask 022

/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf &
mosq_pid=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

stop() {
	kill -TERM "$mosq_pid" "$caddy_pid" 2>/dev/null || true
}
trap stop TERM INT

# Exit as soon as either process stops.
while kill -0 "$mosq_pid" 2>/dev/null && kill -0 "$caddy_pid" 2>/dev/null; do
	sleep 2
done
stop
code=0
wait "$mosq_pid" || code=$?
wait "$caddy_pid" 2>/dev/null || true
exit "$code"

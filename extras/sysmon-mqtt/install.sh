#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
device_name="${2:?"Missing device name!"}"
network_adapters="${3:-}"

# Ensure list of network adapters remains quoted in the heredoc. There appears
# no way to achieve this using something like ${var:+\""$var"\"} — whatever I
# try, I either get no quotes or a literal \" in the output...
if [ -n "$network_adapters" ] ; then
  network_adapters=\""$network_adapters"\"
fi

sysmon_url="https://github.com/thijsputman/home-assistant-config/raw/main/ \
  extras/sysmon-mqtt/sysmon.sh"

if [ -e /etc/systemd/system/sysmon-mqtt.service ] ; then
  systemctl stop sysmon-mqtt
  systemctl disable sysmon-mqtt
  rm /etc/systemd/system/sysmon-mqtt.service
# Assumes dependencies are only relevant on first ever install...
else
  apt update
  apt install -y \
    bash \
    gawk \
    jq \
    mosquitto-clients
fi

wget -O .sysmon-mqtt "$(tr -d ' ' <<< "$sysmon_url")"
chown "${SUDO_USER:-$(whoami)}:" .sysmon-mqtt
chmod +x .sysmon-mqtt

tee /etc/systemd/system/sysmon-mqtt.service <<- EOF > /dev/null
  [Unit]
  Description=Simple system monitoring over MQTT
  After=network-online.target
  Wants=network-online.target
  StartLimitIntervalSec=120
  StartLimitBurst=3

  [Service]
  Type=simple
  Restart=on-failure
  RestartSec=30
  User=${SUDO_USER:-$(whoami)}
  ExecStart=/usr/bin/env bash $(pwd)/.sysmon-mqtt \
    $mqtt_host "$device_name" $network_adapters

  [Install]
  WantedBy=multi-user.target
	EOF
  # N.B., EOF-line should be indented with tabs!

systemctl daemon-reload
systemctl enable sysmon-mqtt

systemctl start sysmon-mqtt

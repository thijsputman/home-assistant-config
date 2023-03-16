#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
device_name="${2:?"Missing device name!"}"

sysmon_url="https://github.com/thijsputman/home-assistant-config/raw/main/ \
  extras/sysmon-mqtt/sysmon.sh"

if [ -e /etc/systemd/system/sysmon-mqtt.service ] ; \
  then systemctl stop sysmon-mqtt ; fi

wget -O sysmon.sh "$(tr -d ' ' <<< "$sysmon_url")"
chmod +x sysmon.sh

if [ ! -e /etc/systemd/system/sysmon-mqtt.service ] ; then

  apt update
  apt install -y \
    bash \
    gawk \
    jq \
    mosquitto-clients

  tee /etc/systemd/system/sysmon-mqtt.service <<- EOF > /dev/null
    [Unit]
    Description=Simple system monitoring over MQTT
    After=network.target

    [Service]
    Type=simple
    Restart=on-failure
    User=$USER
    ExecStart=/usr/bin/env bash $(pwd)/sysmon.sh \
      $mqtt_host "$device_name"

    [Install]
    WantedBy=multi-user.target
		EOF
    # N.B., EOF-line should be indented with tabs!

  systemctl daemon-reload
  systemctl enable sysmon-mqtt

fi

systemctl start sysmon-mqtt

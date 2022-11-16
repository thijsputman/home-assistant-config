#!/usr/bin/env bash

set -eo pipefail

# Update to match environment
container=home-assistant
container_path=~/home-assistant
nvme_path=/path-to-nvme/home-assistant

if [ ! -f $container_path/config/restart-container ] ; then
 exit 0
fi

docker-compose -f $container_path/docker-compose.yml stop $container

# Ensure the NVMe-drive is/gets mounted
ls $nvme_path > /dev/null
stat $nvme_path/home-assistant_v2.db # Feed this through to MAILTO (cron)

docker-compose -f $container_path/docker-compose.yml start $container

rm $container_path/config/restart-container
date +%s >> $container_path/config/var/container-restarts.log

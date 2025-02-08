#!/bin/bash
set -e
CONFIG_FILE="/opt/easy-diffusion/config.yaml"
BKUP_FILE="/opt/easy-diffusion/config-backup/config.yaml"

if [[ ! -f $BKUP_FILE ]]; then
    echo "No backup config found - using present config file"
else
    echo "Backup config found, loading..."
    cp $BKUP_FILE $CONFIG_FILE
fi

nohup bash -c "ls /opt/easy-diffusion/config.yaml | entr -n cp /opt/easy-diffusion/config.yaml /opt/easy-diffusion/config-backup/config.yaml" &

exec "$@"
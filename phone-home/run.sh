#!/bin/bash

# SIGTERM-handler this funciton will be executed when the container receives the SIGTERM signal (when stopping)
term_handler(){
	echo "Stopping..."
	# possible gentle shutdown commands
	exit 0
}

# Setup signal handlers
trap 'term_handler' SIGTERM


echo "Starting..."

# parsing config
CONFIG_PATH=/data/options.json

TARGET_PATH=$(jq --raw-output ".target_path" $CONFIG_PATH)
SSH_PRIV=$(jq --raw-output ".ssh_priv" $CONFIG_PATH)
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
REMOTE_PORT=$(jq --raw-output ".remote_port" $CONFIG_PATH)

# Enforces required env variables
required_vars=(SSH_PRIV TARGET_PATH SSH_USER SSH_HOST REMOTE_PORT)
for required_var in "${required_vars[@]}"; do
    if [[ -z ${!required_var} ]]; then
        error=1
        echo >&2 "Error: $required_var env variable not set."
    fi
done

if [[ -n $error ]]; then
    exit 1
fi

# Setup ssh access
echo "Initializing..."
echo "$SSH_PRIV"$'\n' > /ssh_priv
chmod 600 /ssh_priv

mkdir /root/.ssh

echo -e "\tHostName $SSH_HOST" >> /ssh_config
echo -e "\tUser $SSH_USER" >> /ssh_config
echo -e "\tPort $SSH_PORT" >> /ssh_config
echo -e "\tRemoteForward 8123 homeassistant:$REMOTE_PORT" >> /ssh_config
	

echo "Setting up SSH tunnel..."
ssh -N -f -F /ssh_config home

while true
do
echo "Starting rsync backup to $SSH_HOST"
rsync -az -e "ssh -p $SSH_PORT -i /ssh_priv -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" /backup/ $SSH_USER@$SSH_HOST:$TARGET_PATH
echo "Finished rsync backup to $SSH_HOST"
# sleep 24h
sleep 86400
done

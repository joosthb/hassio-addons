#!/bin/bash

# SIGTERM-handler this funciton will be executed when the container receives the SIGTERM signal (when stopping)
term_handler(){
	echo "Stopping..."
	ifdown $IF_INT
	ip link set $IF_INT down
	ip addr flush dev $IF_INT
	exit 0
}

# Setup signal handlers
trap 'term_handler' SIGTERM

echo "Starting..."
# Want to host ap on internal wifi adapter, wlan index numbers sometimes changes after reboot/powerdown so
# Dirty hack to find ext and internal wlan interfaces
for PATHS in `find /sys/class/net/wlan?/device/driver/module/drivers/usb:* | cut -d'/' -f5,10 | sed 's/\/usb\:/,/'`
do
  IFS=',' read -r -a TUPLE <<< $PATHS
  if [[ ${TUPLE[1]} == "brcmfmac" ]]; then
    IF_INT=${TUPLE[0]}
  else
    IF_EXT=${TUPLE[0]}
  fi
done

echo "Found internal interface: $IF_INT"
echo "Set nmcli managed no"
nmcli dev set $IF_INT managed no

CONFIG_PATH=/data/options.json

SSID=$(jq --raw-output ".ssid" $CONFIG_PATH)
WPA_PASSPHRASE=$(jq --raw-output ".wpa_passphrase" $CONFIG_PATH)
CHANNEL=$(jq --raw-output ".channel" $CONFIG_PATH)
ADDRESS=$(jq --raw-output ".address" $CONFIG_PATH)
NETMASK=$(jq --raw-output ".netmask" $CONFIG_PATH)
BROADCAST=$(jq --raw-output ".broadcast" $CONFIG_PATH)
DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)

# Enforces required env variables
required_vars=(SSID WPA_PASSPHRASE CHANNEL ADDRESS NETMASK BROADCAST DOMAIN)
for required_var in "${required_vars[@]}"; do
    if [[ -z ${!required_var} ]]; then
        error=1
        echo >&2 "Error: $required_var env variable not set."
    fi
done

if [[ -n $error ]]; then
    exit 1
fi

# Setup hostapd.conf
echo "Setup hostapd ..."
echo "ssid=$SSID"$'\n' >> /hostapd.conf
echo "wpa_passphrase=$WPA_PASSPHRASE"$'\n' >> /hostapd.conf
echo "channel=$CHANNEL"$'\n' >> /hostapd.conf
echo "interface=$IF_INT"$'\n' >> /hostapd.conf

# Setup interface
echo "Setup interface ..."
echo "iface $IF_INT inet static"$'\n' >> /etc/network/interfaces
echo "address $ADDRESS"$'\n' >> /etc/network/interfaces
echo "netmask $NETMASK"$'\n' >> /etc/network/interfaces
echo "broadcast $BROADCAST"$'\n' >> /etc/network/interfaces

# nmcli con add type wifi ifname $IF_INT con-name local_ap autoconnect no ssid Herbert
# nmcli con modify local_ap 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
# nmcli con modify local_ap wifi-sec.psk "veryveryhardpassword1234"
# nmcli con modify local_ap wifi-sec.key-mgmt wpa-psk
# nmcli con up local_ap


# Make homeassistant entry in hosts file
echo "$ADDRESS homeassistant" >> /etc/hosts

ifdown $IF_INT
ifup $IF_INT

# echo "Configuring iptables - packet forwarding"
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# iptables -A FORWARD -i eth0 -o $IF_INT -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i $IF_INT -o eth0 -j ACCEPT

echo "Configuring and starting dnsmasq daemon ..."
echo "interface=$IF_INT"$'\n' >> /etc/dnsmasq.conf
echo "domain=$DOMAIN"$'\n' >> /etc/dnsmasq.conf
dnsmasq

echo "Starting HostAP daemon ..."
# debugging:
# hostapd -d /hostapd.conf & wait ${!}
hostapd /hostapd.conf & wait ${!}


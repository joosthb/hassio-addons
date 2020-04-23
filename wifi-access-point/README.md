## About

This addon provides a local WiFi access point to create an isolated network for your IOT devices.

### Caveats
When using an external wifi adapter on your Raspberry Pi the index of the devicename (eg wlan1, wlan0) might change after reboot. To prevent overwriting your uplink connection we have to fix the mac-address by adding it to the [802-11-wireless] block your network config file (eg /etc/NetworkManager/system-connections/my-network)

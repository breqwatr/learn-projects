# Add a network interface

The netplan file for [Add a network interface](https://learn.breqwatr.cloud/how-to/networking/add-a-network-interface/) on learn.breqwatr.cloud. Follow the page: it attaches the interface first.

## Files

- `60-second-interface.yaml`: brings up the second interface with DHCP, without taking its routes.

## Before you use them

Replace `ens7` with the new interface's name from `ip -br addr`, and save the file as `/etc/netplan/60-second-interface.yaml` on the instance.

## Versions

Tested on Ubuntu 24.04 LTS.

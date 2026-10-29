# Self-hosted VPN with WireGuard

The WireGuard files for [Self-hosted VPN with WireGuard](https://learn.breqwatr.workers.dev/how-to/remote-access/self-hosted-vpn/) on learn.breqwatr.cloud. Follow the page: it sets up the VPN instance and explains each line.

## Files

- `wg0.conf`: the VPN instance's configuration.
- `client.conf`: your computer's configuration.

## Before you use them

Replace the placeholders with your keys, the VPN instance's floating IP and your network's address range. The keys stay on the machines they were made on, and out of version control.

## Versions

Tested with WireGuard from Ubuntu 24.04 LTS.

# cloudbase-init

The script for [cloudbase-init](https://learn.breqwatr.cloud/how-to/windows/cloudbase-init/) on learn.breqwatr.cloud. Follow the page: it passes the script as user data when you launch a Windows instance.

## Files

- `winrm-https.ps1`: adds a WinRM listener on HTTPS with a self-signed certificate, and opens TCP 5986 in the Windows firewall.

## Before you use them

Port 5986 answers only if the instance's security group allows it. Allow it from your own IP address.

## Versions

Tested on Windows Server 2025.

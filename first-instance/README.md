# 4.1 Your first instance, three ways

The code for [Your first instance, three ways](https://learn.breqwatr.workers.dev/tutorials/first-instance/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

A Linux and a Windows instance, each booting from a volume, with a security group open to your IP and floating IPs. The page also builds them in the Breqwatr Cloud Portal and with the OpenStack CLI; this folder holds the OpenTofu way.

## Files

- `.terraform.lock.hcl`
- `main.tf`

## Before you run it

Replace the placeholders in `main.tf` with your IP address, image names and external network.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0.

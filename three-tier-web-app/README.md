# 4.4 A three-tier web app

The code for [A three-tier web app](https://learn.breqwatr.cloud/tutorials/three-tier-web-app/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

A web tier and an app tier, each behind its own Octavia load balancer with a health monitor, and a PostgreSQL database whose data lives on its own volume.

## Files

- `.terraform.lock.hcl`
- `app.tf`
- `database.tf`
- `network.tf`
- `outputs.tf`
- `security.tf`
- `templates/app.sh`
- `templates/db.sh`
- `templates/web.sh`
- `terraform.tfvars.example`
- `variables.tf`
- `versions.tf`
- `web.tf`

## Before you run it

Copy `terraform.tfvars.example` to `terraform.tfvars` and set your values.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0, random provider 3.9.1.

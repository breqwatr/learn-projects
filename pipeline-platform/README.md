# 4.8 Build your own pipeline platform

The code for [Build your own pipeline platform](https://learn.breqwatr.workers.dev/tutorials/pipeline-platform/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

Gitea and Woodpecker CI on two instances you own, behind Caddy with Let's Encrypt certificates, with PostgreSQL and a data volume that outlasts rebuilds.

## Files

- `.terraform.lock.hcl`
- `agent.tf`
- `network.tf`
- `outputs.tf`
- `platform.tf`
- `security.tf`
- `templates/agent.sh`
- `templates/platform.sh`
- `terraform.tfvars.example`
- `variables.tf`
- `versions.tf`

## Before you run it

Copy `terraform.tfvars.example` to `terraform.tfvars` and set your values. Gitea and Woodpecker CI are open-source software you run yourself, not Breqwatr services.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0, random provider 3.9.1; Gitea 28.1.0, Woodpecker CI 3.19.0, Caddy 2.11.7, PostgreSQL 18.4, Docker Engine from Docker's apt repository on Ubuntu 24.04.

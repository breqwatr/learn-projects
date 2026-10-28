# 4.5 Rebuild, don't repair

The code for [Rebuild, don't repair](https://learn.breqwatr.workers.dev/tutorials/rebuild-dont-repair/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

The 4.4 application with its data volume protected by `prevent_destroy`, ready to replace instances from code.

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

Copy `terraform.tfvars.example` to `terraform.tfvars` and set your values. The `--8<--` comments in `database.tf` mark the part the page shows.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0, random provider 3.9.1.

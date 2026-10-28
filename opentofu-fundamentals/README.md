# 4.2 OpenTofu fundamentals

The code for [OpenTofu fundamentals](https://learn.breqwatr.workers.dev/tutorials/opentofu-fundamentals/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

The 4.1 build as a reusable project: pinned versions, variables, and a module that builds one instance, called once for each.

## Files

- `.gitignore`
- `.terraform.lock.hcl`
- `main.tf`
- `modules/instance/main.tf`
- `modules/instance/outputs.tf`
- `modules/instance/variables.tf`
- `modules/instance/versions.tf`
- `outputs.tf`
- `terraform.tfvars.example`
- `variables.tf`
- `versions.tf`

## Before you run it

Copy `terraform.tfvars.example` to `terraform.tfvars` and set your values.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0.

# 4.9 Deploy from the pipeline

The code for [Deploy from the pipeline](https://learn.breqwatr.cloud/tutorials/deploy-from-pipeline/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

The files you commit to your own Gitea repository: a small nginx instance and a Woodpecker pipeline that plans on pull requests and applies on merges to `main`, with OpenTofu state in PostgreSQL.

## Files

- `.gitignore`
- `.terraform.lock.hcl`
- `.woodpecker.yaml`
- `index.html`
- `main.tf`
- `variables.tf`
- `versions.tf`
- `web.sh`

## Before you run it

Replace the four placeholders in `.woodpecker.yaml` with your values. The pipeline's credential and connection string are Woodpecker secrets, never files.

## Versions

Tested with OpenTofu 1.13.1 on your computer and in the pipeline (`ghcr.io/opentofu/opentofu:1.13.1`), OpenStack provider 3.4.0.

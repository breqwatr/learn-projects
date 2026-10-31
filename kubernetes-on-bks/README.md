# 4.7 Kubernetes on BKS

The code for [Kubernetes on BKS](https://learn.breqwatr.cloud/tutorials/kubernetes-on-bks/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

The 4.4 shop app on a BKS cluster: the cluster in OpenTofu, and the app and its database as Kubernetes manifests, reached through a Gateway.

## Files

- `.gitignore`
- `.terraform.lock.hcl`
- `cluster.tf`
- `manifests/app.py`
- `manifests/app.yaml`
- `manifests/db.env.example`
- `manifests/db.yaml`
- `manifests/gateway.yaml`
- `manifests/hpa.yaml`
- `manifests/kustomization.yaml`
- `manifests/namespace.yaml`
- `outputs.tf`
- `variables.tf`
- `versions.tf`

## Before you run it

The cluster needs an unrestricted application credential: the page explains why, and what it allows. Copy `manifests/db.env.example` to `manifests/db.env` and set the database password.

## Versions

Tested with OpenTofu 1.13.1, OpenStack provider 3.4.0, cluster template `debian-13-v1.36.1`, PostgreSQL 17.6, Python 3.14.0, psycopg2-binary 2.9.12, NGINX Gateway Fabric 2.8.0 and metrics-server 0.9.0.

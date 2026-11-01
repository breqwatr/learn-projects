# Gateway API

The manifests for [Gateway API](https://learn.breqwatr.cloud/how-to/kubernetes/gateway-api/) on learn.breqwatr.cloud. Follow the page: it installs the controller first and explains each resource.

## Files

- `gateway.yaml`: a Gateway listening for HTTP on port 80.
- `route.yaml`: an HTTPRoute that splits traffic between two Services by weight.

## Before you use them

`route.yaml` sends traffic to Services named `app-v1` and `app-v2` on port 8080. Change the names and port to your own Services.

## Versions

Tested with NGINX Gateway Fabric 2.8.0 on a BKS cluster from the `debian-13-v1.36.1` template.

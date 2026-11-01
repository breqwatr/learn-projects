# Horizontal pod autoscaling

The manifests for [Horizontal pod autoscaling](https://learn.breqwatr.cloud/how-to/kubernetes/horizontal-pod-autoscaling/) on learn.breqwatr.cloud. Follow the page: it installs metrics-server first.

## Files

- `web.yaml`: a small web app with a CPU request of 200m, and its Service.
- `hpa.yaml`: a HorizontalPodAutoscaler that keeps average CPU use near 50% of the request, with 1 to 5 replicas.

## Before you use them

The autoscaler needs metrics-server, which a BKS cluster doesn't include. The page shows how to install it.

## Versions

Tested with metrics-server 0.9.0 on a BKS cluster from the `debian-13-v1.36.1` template.

# Cluster autoscaling

The manifest for [Cluster autoscaling](https://learn.breqwatr.cloud/how-to/kubernetes/cluster-autoscaling/) on learn.breqwatr.cloud. Follow the page: it turns on autoscaling for the cluster first.

## Files

- `scale-test.yaml`: a deployment that asks for half a vCPU per pod, to scale up until the workers run out of room.

## Before you use them

Delete the deployment when you're done, so the cluster can scale back down.

## Versions

Tested on a BKS cluster from the `debian-13-v1.36.1` template.

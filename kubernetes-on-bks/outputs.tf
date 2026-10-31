output "kubeconfig" {
  description = "kubectl's configuration for the cluster, with an administrator's certificate"
  value       = openstack_containerinfra_cluster_v1.shop.kubeconfig.raw_config
  sensitive   = true
}

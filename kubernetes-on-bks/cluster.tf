data "openstack_containerinfra_clustertemplate_v1" "k8s" {
  name = var.cluster_template
}

resource "openstack_containerinfra_cluster_v1" "shop" {
  name                = var.name
  cluster_template_id = data.openstack_containerinfra_clustertemplate_v1.k8s.id
  master_count        = 1
  node_count          = var.worker_count
}

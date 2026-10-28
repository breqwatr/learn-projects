output "url" {
  value = "http://${openstack_networking_floatingip_v2.web.address}/"
}

output "address" {
  description = "The instance's floating IP address"
  value       = openstack_networking_floatingip_v2.this.address
}

output "floating_ip" {
  description = "Point git.<domain> and ci.<domain> at this address"
  value       = openstack_networking_floatingip_v2.platform.address
}

output "gitea_url" {
  value = "https://git.${var.domain}/"
}

output "woodpecker_url" {
  value = "https://ci.${var.domain}/"
}

output "gitea_admin_password" {
  value     = random_password.gitea_admin.result
  sensitive = true
}

output "pg_conn_str" {
  description = "Connection string the pipeline uses for OpenTofu state"
  value       = "postgres://tfstate:${random_password.postgres["tfstate"].result}@${openstack_networking_port_v2.platform.all_fixed_ips[0]}:5432/tfstate?sslmode=disable"
  sensitive   = true
}

resource "openstack_networking_secgroup_v2" "platform" {
  name = "${var.prefix}-platform"
}

resource "openstack_networking_secgroup_v2" "agent" {
  name = "${var.prefix}-agent"
}

locals {
  # The router's own address: traffic from the agent to git.<domain> comes from it
  router_ip = "${openstack_networking_router_v2.ci.external_fixed_ip[0].ip_address}/32"

  platform_rules = {
    acme  = { port = 80, from = "0.0.0.0/0" }
    https = { port = 443, from = var.my_ip }
    agent = { port = 443, from = local.router_ip }
    ssh   = { port = 22, from = var.my_ip }
  }
}

# Port 80 is open to the internet for Let's Encrypt's HTTP-01 challenge and the
# redirect to HTTPS; everything else is limited to you
resource "openstack_networking_secgroup_rule_v2" "platform" {
  for_each = local.platform_rules

  security_group_id = openstack_networking_secgroup_v2.platform.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.from
}

# The agent reaches the Woodpecker server (9000) and PostgreSQL (5432) over the private network
resource "openstack_networking_secgroup_rule_v2" "from_agent" {
  for_each = { grpc = 9000, postgres = 5432 }

  security_group_id = openstack_networking_secgroup_v2.platform.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_group_id   = openstack_networking_secgroup_v2.agent.id
}

resource "openstack_networking_secgroup_rule_v2" "agent_ssh" {
  security_group_id = openstack_networking_secgroup_v2.agent.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip
}

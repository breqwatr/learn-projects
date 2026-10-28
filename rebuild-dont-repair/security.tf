# Load balancers reach their members from addresses on the subnet,
# so the web and app tiers accept their port from the subnet.
resource "openstack_networking_secgroup_v2" "web" {
  name = "${var.prefix}-web"
}

resource "openstack_networking_secgroup_rule_v2" "web_http" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.subnet_cidr
}

resource "openstack_networking_secgroup_v2" "app" {
  name = "${var.prefix}-app"
}

resource "openstack_networking_secgroup_rule_v2" "app_http" {
  security_group_id = openstack_networking_secgroup_v2.app.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = var.subnet_cidr
}

# The database accepts connections only from instances in the app group.
resource "openstack_networking_secgroup_v2" "db" {
  name = "${var.prefix}-db"
}

resource "openstack_networking_secgroup_rule_v2" "db_postgres" {
  security_group_id = openstack_networking_secgroup_v2.db.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = openstack_networking_secgroup_v2.app.id
}

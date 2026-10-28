data "openstack_networking_network_v2" "this" {
  name = var.network_name
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

resource "openstack_compute_keypair_v2" "this" {
  name       = "${var.prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "openstack_networking_secgroup_v2" "access" {
  name = "${var.prefix}-access"
}

resource "openstack_networking_secgroup_rule_v2" "access" {
  for_each = { ssh = 22, rdp = 3389 }

  security_group_id = openstack_networking_secgroup_v2.access.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = var.my_ip
}

module "web_01" {
  source = "./modules/instance"

  name               = "${var.prefix}-web-01"
  image_name         = var.linux_image
  flavour            = var.linux_flavour
  volume_size        = 20
  key_pair           = openstack_compute_keypair_v2.this.name
  network_id         = data.openstack_networking_network_v2.this.id
  security_group_ids = [data.openstack_networking_secgroup_v2.default.id, openstack_networking_secgroup_v2.access.id]
  external_network   = var.external_network
}

module "win_01" {
  source = "./modules/instance"

  name               = "${var.prefix}-win-01"
  image_name         = var.windows_image
  flavour            = "v1.c2r8"
  volume_size        = 80
  network_id         = data.openstack_networking_network_v2.this.id
  security_group_ids = [data.openstack_networking_secgroup_v2.default.id, openstack_networking_secgroup_v2.access.id]
  external_network   = var.external_network
}

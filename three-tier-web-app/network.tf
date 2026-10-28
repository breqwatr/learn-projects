data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.linux_image
  most_recent = true
}

resource "openstack_networking_network_v2" "app" {
  name = "${var.prefix}-net"
}

resource "openstack_networking_subnet_v2" "app" {
  name            = "${var.prefix}-subnet"
  network_id      = openstack_networking_network_v2.app.id
  cidr            = var.subnet_cidr
  dns_nameservers = ["1.1.1.1", "1.0.0.1"]
}

resource "openstack_networking_router_v2" "app" {
  name                = "${var.prefix}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "app" {
  router_id = openstack_networking_router_v2.app.id
  subnet_id = openstack_networking_subnet_v2.app.id
}

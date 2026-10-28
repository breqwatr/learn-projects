data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.linux_image
  most_recent = true
}

resource "openstack_networking_network_v2" "site" {
  name = "${var.prefix}-net"
}

resource "openstack_networking_subnet_v2" "site" {
  name            = "${var.prefix}-subnet"
  network_id      = openstack_networking_network_v2.site.id
  cidr            = "10.50.0.0/24"
  dns_nameservers = ["1.1.1.1", "1.0.0.1"]
}

resource "openstack_networking_router_v2" "site" {
  name                = "${var.prefix}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "site" {
  router_id = openstack_networking_router_v2.site.id
  subnet_id = openstack_networking_subnet_v2.site.id
}

resource "openstack_networking_secgroup_v2" "site" {
  name = "${var.prefix}-web"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.site.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.my_ip
}

resource "openstack_networking_port_v2" "site" {
  name               = "${var.prefix}-web-01"
  network_id         = openstack_networking_network_v2.site.id
  security_group_ids = [openstack_networking_secgroup_v2.site.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.site.id
  }
}

# The page is part of the instance's first-boot script, so a change to
# index.html replaces the instance: rebuild, don't repair
resource "openstack_compute_instance_v2" "site" {
  name        = "${var.prefix}-web-01"
  flavor_name = "v1.c1r2"
  user_data = templatefile("${path.module}/web.sh", {
    page = file("${path.module}/index.html")
  })

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 20
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.site.id
  }

  depends_on = [openstack_networking_router_interface_v2.site]
}

resource "openstack_networking_floatingip_v2" "site" {
  pool       = var.external_network
  port_id    = openstack_networking_port_v2.site.id
  depends_on = [openstack_networking_router_interface_v2.site]
}

output "url" {
  value = "http://${openstack_networking_floatingip_v2.site.address}/"
}

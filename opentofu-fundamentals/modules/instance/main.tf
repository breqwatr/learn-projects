data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_networking_port_v2" "this" {
  name               = var.name
  network_id         = var.network_id
  security_group_ids = var.security_group_ids
}

resource "openstack_compute_instance_v2" "this" {
  name        = var.name
  flavor_name = var.flavour
  key_pair    = var.key_pair

  block_device {
    uuid                  = data.openstack_images_image_v2.this.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.volume_size
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.this.id
  }
}

resource "openstack_networking_floatingip_v2" "this" {
  pool       = var.external_network
  port_id    = openstack_networking_port_v2.this.id
  depends_on = [openstack_compute_instance_v2.this]
}

resource "random_password" "db" {
  length  = 24
  special = false
}

# The data lives on its own volume, so it outlasts any one database instance
resource "openstack_blockstorage_volume_v3" "db_data" {
  name = "${var.prefix}-db-data"
  size = 10
}

# A port of its own keeps the database's address the same when the instance is rebuilt
resource "openstack_networking_port_v2" "db" {
  name               = "${var.prefix}-db"
  network_id         = openstack_networking_network_v2.app.id
  security_group_ids = [openstack_networking_secgroup_v2.db.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.app.id
  }
}

resource "openstack_compute_instance_v2" "db" {
  name        = "${var.prefix}-db-01"
  flavor_name = var.flavour
  user_data = templatefile("${path.module}/templates/db.sh", {
    subnet_cidr = var.subnet_cidr
    db_password = random_password.db.result
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
    port = openstack_networking_port_v2.db.id
  }

  depends_on = [openstack_networking_router_interface_v2.app]
}

resource "openstack_compute_volume_attach_v2" "db_data" {
  instance_id = openstack_compute_instance_v2.db.id
  volume_id   = openstack_blockstorage_volume_v3.db_data.id
}

resource "openstack_compute_keypair_v2" "ci" {
  name       = "${var.prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "random_password" "postgres" {
  for_each = toset(["admin", "gitea", "woodpecker", "tfstate"])
  length   = 24
  special  = false
}

resource "random_password" "gitea_admin" {
  length  = 20
  special = false
}

resource "random_password" "agent" {
  length  = 32
  special = false
}

# Gitea's repositories, the databases and Caddy's certificates live on this
# volume, so they outlast any rebuild of the platform instance
resource "openstack_blockstorage_volume_v3" "data" {
  name = "${var.prefix}-platform-data"
  size = 20

  lifecycle {
    prevent_destroy = true
  }
}

# A fixed address, so the agent and the pipeline always find the platform
resource "openstack_networking_port_v2" "platform" {
  name               = "${var.prefix}-platform"
  network_id         = openstack_networking_network_v2.ci.id
  security_group_ids = [openstack_networking_secgroup_v2.platform.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.ci.id
  }
}

resource "openstack_compute_instance_v2" "platform" {
  name        = "${var.prefix}-platform-01"
  flavor_name = "v1.c2r8"
  key_pair    = openstack_compute_keypair_v2.ci.name
  user_data = templatefile("${path.module}/templates/platform.sh", {
    domain            = var.domain
    private_ip        = openstack_networking_port_v2.platform.all_fixed_ips[0]
    admin_username    = var.admin_username
    admin_email       = var.admin_email
    admin_password    = random_password.gitea_admin.result
    pg_admin          = random_password.postgres["admin"].result
    pg_gitea          = random_password.postgres["gitea"].result
    pg_tfstate        = random_password.postgres["tfstate"].result
    pg_woodpecker     = random_password.postgres["woodpecker"].result
    agent_secret      = random_password.agent.result
    woodpecker_client = var.woodpecker_client
    woodpecker_secret = var.woodpecker_secret
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
    port = openstack_networking_port_v2.platform.id
  }

  depends_on = [openstack_networking_router_interface_v2.ci]
}

resource "openstack_compute_volume_attach_v2" "data" {
  instance_id = openstack_compute_instance_v2.platform.id
  volume_id   = openstack_blockstorage_volume_v3.data.id
}

resource "openstack_networking_floatingip_v2" "platform" {
  pool       = var.external_network
  port_id    = openstack_networking_port_v2.platform.id
  depends_on = [openstack_networking_router_interface_v2.ci]
}

terraform {
  required_version = ">= 1.13"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }
}

# Reads the cloud named in the OS_CLOUD environment variable from clouds.yaml
provider "openstack" {}

locals {
  my_ip            = "<your-ip>/32"
  external_network = "<external-network>"
}

data "openstack_networking_network_v2" "default" {
  name = "default"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

data "openstack_images_image_v2" "linux" {
  name        = "<linux-image>"
  most_recent = true
}

data "openstack_images_image_v2" "windows" {
  name        = "<windows-image>"
  most_recent = true
}

resource "openstack_compute_keypair_v2" "first_instance" {
  name       = "first-instance"
  public_key = file(pathexpand("~/.ssh/first-instance.pub"))
}

resource "openstack_networking_secgroup_v2" "first_instance" {
  name = "first-instance"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.first_instance.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.my_ip
}

resource "openstack_networking_secgroup_rule_v2" "rdp" {
  security_group_id = openstack_networking_secgroup_v2.first_instance.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  remote_ip_prefix  = local.my_ip
}

# A port for each instance, so its floating IP can be attached to it
resource "openstack_networking_port_v2" "web_01" {
  name               = "web-01"
  network_id         = data.openstack_networking_network_v2.default.id
  security_group_ids = [data.openstack_networking_secgroup_v2.default.id, openstack_networking_secgroup_v2.first_instance.id]
}

resource "openstack_networking_port_v2" "win_01" {
  name               = "win-01"
  network_id         = data.openstack_networking_network_v2.default.id
  security_group_ids = [data.openstack_networking_secgroup_v2.default.id, openstack_networking_secgroup_v2.first_instance.id]
}

resource "openstack_compute_instance_v2" "web_01" {
  name        = "web-01"
  flavor_name = "v1.c1r2"
  key_pair    = openstack_compute_keypair_v2.first_instance.name

  block_device {
    uuid                  = data.openstack_images_image_v2.linux.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 20
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.web_01.id
  }
}

resource "openstack_compute_instance_v2" "win_01" {
  name        = "win-01"
  flavor_name = "v1.c2r8"

  block_device {
    uuid                  = data.openstack_images_image_v2.windows.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 80
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.win_01.id
  }
}

resource "openstack_networking_floatingip_v2" "web_01" {
  pool       = local.external_network
  port_id    = openstack_networking_port_v2.web_01.id
  depends_on = [openstack_compute_instance_v2.web_01]
}

resource "openstack_networking_floatingip_v2" "win_01" {
  pool       = local.external_network
  port_id    = openstack_networking_port_v2.win_01.id
  depends_on = [openstack_compute_instance_v2.win_01]
}

output "web_01_address" {
  value = openstack_networking_floatingip_v2.web_01.address
}

output "win_01_address" {
  value = openstack_networking_floatingip_v2.win_01.address
}

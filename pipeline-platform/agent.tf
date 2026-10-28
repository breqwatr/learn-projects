resource "openstack_compute_instance_v2" "agent" {
  name            = "${var.prefix}-agent-01"
  flavor_name     = "v1.c1r4"
  key_pair        = openstack_compute_keypair_v2.ci.name
  security_groups = [openstack_networking_secgroup_v2.agent.name]
  user_data = templatefile("${path.module}/templates/agent.sh", {
    server       = "${openstack_networking_port_v2.platform.all_fixed_ips[0]}:9000"
    agent_secret = random_password.agent.result
  })

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 30
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.ci.id
  }

  depends_on = [openstack_networking_router_interface_v2.ci]
}

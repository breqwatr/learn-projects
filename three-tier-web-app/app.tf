resource "openstack_compute_instance_v2" "app" {
  count           = 2
  name            = format("%s-app-%02d", var.prefix, count.index + 1)
  flavor_name     = var.flavour
  security_groups = [openstack_networking_secgroup_v2.app.name]
  user_data = templatefile("${path.module}/templates/app.sh", {
    db_host     = openstack_networking_port_v2.db.all_fixed_ips[0]
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
    uuid = openstack_networking_network_v2.app.id
  }
}

# An internal load balancer: the web tier reaches the app tier through it
resource "openstack_lb_loadbalancer_v2" "app" {
  name          = "${var.prefix}-app-lb"
  vip_subnet_id = openstack_networking_subnet_v2.app.id
}

resource "openstack_lb_listener_v2" "app" {
  name            = "${var.prefix}-app-http"
  loadbalancer_id = openstack_lb_loadbalancer_v2.app.id
  protocol        = "HTTP"
  protocol_port   = 8080
}

resource "openstack_lb_pool_v2" "app" {
  name        = "${var.prefix}-app-pool"
  listener_id = openstack_lb_listener_v2.app.id
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
}

resource "openstack_lb_monitor_v2" "app" {
  name        = "${var.prefix}-app-health"
  pool_id     = openstack_lb_pool_v2.app.id
  type        = "HTTP"
  url_path    = "/health"
  delay       = 5
  timeout     = 3
  max_retries = 2
}

resource "openstack_lb_member_v2" "app" {
  count         = 2
  pool_id       = openstack_lb_pool_v2.app.id
  address       = openstack_compute_instance_v2.app[count.index].access_ip_v4
  protocol_port = 8080
  subnet_id     = openstack_networking_subnet_v2.app.id
}

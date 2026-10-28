resource "openstack_compute_instance_v2" "web" {
  count           = 2
  name            = format("%s-web-%02d", var.prefix, count.index + 1)
  flavor_name     = var.flavour
  security_groups = [openstack_networking_secgroup_v2.web.name]
  user_data = templatefile("${path.module}/templates/web.sh", {
    app_address = openstack_lb_loadbalancer_v2.app.vip_address
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

# The public load balancer, with a floating IP for internet traffic
resource "openstack_lb_loadbalancer_v2" "web" {
  name          = "${var.prefix}-web-lb"
  vip_subnet_id = openstack_networking_subnet_v2.app.id
}

resource "openstack_lb_listener_v2" "web" {
  name            = "${var.prefix}-web-http"
  loadbalancer_id = openstack_lb_loadbalancer_v2.web.id
  protocol        = "HTTP"
  protocol_port   = 80
}

resource "openstack_lb_pool_v2" "web" {
  name        = "${var.prefix}-web-pool"
  listener_id = openstack_lb_listener_v2.web.id
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
}

resource "openstack_lb_monitor_v2" "web" {
  name        = "${var.prefix}-web-health"
  pool_id     = openstack_lb_pool_v2.web.id
  type        = "HTTP"
  url_path    = "/health"
  delay       = 5
  timeout     = 3
  max_retries = 2
}

resource "openstack_lb_member_v2" "web" {
  count         = 2
  pool_id       = openstack_lb_pool_v2.web.id
  address       = openstack_compute_instance_v2.web[count.index].access_ip_v4
  protocol_port = 80
  subnet_id     = openstack_networking_subnet_v2.app.id
}

resource "openstack_networking_floatingip_v2" "web" {
  pool       = var.external_network
  port_id    = openstack_lb_loadbalancer_v2.web.vip_port_id
  depends_on = [openstack_networking_router_interface_v2.app]
}

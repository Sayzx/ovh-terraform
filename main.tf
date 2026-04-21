terraform {
  required_version = ">= 1.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }
  }
}

provider "openstack" {
  auth_url = var.openstack_auth_url
  region   = var.region
}

# SECURITY GROUP

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = data.openstack_networking_secgroup_v2.default.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
}


# SSH KEYPAIR

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = file(pathexpand(var.public_key_path))
}


# INSTANCE

resource "openstack_compute_instance_v2" "vm" {
  name        = var.instance_name
  flavor_name = var.flavor_name
  image_name  = var.image_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  security_groups = [
    data.openstack_networking_secgroup_v2.default.name
  ]

  network {
    name = var.public_network_name
  }

  lifecycle {
    # Recommended by OVH docs: avoid drift when base image labels evolve.
    ignore_changes = [image_name]
  }
}

# PUBLIC IP

resource "openstack_networking_floatingip_v2" "ip" {
  pool = var.public_network_name
}

resource "openstack_networking_floatingip_associate_v2" "ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.ip.address
  port_id     = openstack_compute_instance_v2.vm.network.0.port
}
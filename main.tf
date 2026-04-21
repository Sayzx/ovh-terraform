terraform {
  required_version = ">= 1.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.40"
    }
  }
}

provider "openstack" {
  region = var.region
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

locals {
  service_name = var.project_id
}

# NETWORK 

resource "ovh_cloud_project_network_private" "vpc" {
  service_name = local.service_name
  name         = var.private_network_name
  regions      = [var.region]
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = local.service_name
  network_id   = ovh_cloud_project_network_private.vpc.id

  region     = var.region
  network    = var.private_subnet_cidr
  start      = var.private_subnet_start_ip
  end        = var.private_subnet_end_ip
  dhcp       = true
  no_gateway = true
}

# SECURITY GROUP

resource "openstack_networking_secgroup_v2" "sg" {
  name         = var.security_group_name
  description  = "Allow SSH and HTTP"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}


# INSTANCE (EC2 équivalent)

resource "openstack_compute_instance_v2" "vm" {
  name        = var.instance_name
  flavor_name = var.flavor_name
  image_name  = var.image_name
  key_pair    = var.ssh_key_name

  security_groups = [
    openstack_networking_secgroup_v2.sg.name
  ]

  network {
    name = var.public_network_name
  }

  network {
    name = ovh_cloud_project_network_private.vpc.name
  }

  lifecycle {
    # Recommended by OVH docs: avoid drift when base image labels evolve.
    ignore_changes = [image_name]
  }

  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

# PUBLIC IP

resource "openstack_networking_floatingip_v2" "ip" {
  pool = var.public_network_name
}

resource "openstack_networking_floatingip_associate_v2" "ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.ip.address
  port_id     = openstack_compute_instance_v2.vm.network.0.port
}
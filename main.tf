terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.40"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

# NETWORK 

resource "ovh_cloud_project_network_private" "vpc" {
  service_name = var.project_id
  name         = "vpc-main"
  regions      = ["GRA11"]
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = var.project_id
  network_id   = ovh_cloud_project_network_private.vpc.id

  region  = "GRA11"
  network = "10.0.1.0/24"
  start   = "10.0.1.0/24"
  dhcp    = true
}

# SECURITY GROUP

resource "ovh_cloud_project_security_group" "sg" {
  service_name = var.project_id
  name         = "web-sg"
  description  = "Allow SSH and HTTP"
}

resource "ovh_cloud_project_security_group_rule" "ssh" {
  service_name        = var.project_id
  security_group_id   = ovh_cloud_project_security_group.sg.id

  direction = "ingress"
  protocol  = "tcp"
  port_range = "22"
  ethertype  = "IPv4"
  remote     = "0.0.0.0/0"
}

resource "ovh_cloud_project_security_group_rule" "http" {
  service_name        = var.project_id
  security_group_id   = ovh_cloud_project_security_group.sg.id

  direction = "ingress"
  protocol  = "tcp"
  port_range = "80"
  ethertype  = "IPv4"
  remote     = "0.0.0.0/0"
}


# INSTANCE (EC2 équivalent)

resource "ovh_cloud_project_instance" "vm" {
  service_name = var.project_id

  name        = "sayzx-vm-debian"
  region      = "GRA11"
  flavor_name = "c2-30"
  image_name  = "Debian 12"

  security_groups = [
    ovh_cloud_project_security_group.sg.name
  ]

  ssh_key_name = var.ssh_key_name
}

# PUBLIC IP

resource "ovh_cloud_project_instance_ip" "ip" {
  service_name = var.project_id
  instance_id  = ovh_cloud_project_instance.vm.id
}
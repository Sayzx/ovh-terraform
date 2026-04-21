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

resource "ovh_cloud_project_instance" "vm" {
  service_name = var.project_id

  name       = "sayzx-vm-debian"
  region     = "GRA11"
  flavor_name = "d2-2"

  image_name = "Debian 12"
}

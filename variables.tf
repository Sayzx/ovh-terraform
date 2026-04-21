variable "region" {
	description = "OpenStack region used for the instance"
	type        = string
	default     = "GRA9"
}

variable "openstack_auth_url" {
	description = "OpenStack authentication URL for OVH Public Cloud"
	type        = string
	default     = "https://auth.cloud.ovh.net/v3/"
}

variable "public_network_name" {
	description = "OpenStack public network pool name"
	type        = string
	default     = "Ext-Net"
}

variable "keypair_name" {
	description = "Name of the OpenStack SSH keypair to create"
	type        = string
	default     = "sayzx"
}

variable "public_key_path" {
	description = "Path to the local SSH public key"
	type        = string
	default     = "~/.ssh/id_ed25519.pub"
}

variable "instance_name" {
	description = "Name of the compute instance"
	type        = string
	default     = "sayzx-vm-debian"
}

variable "flavor_name" {
	description = "OVH flavor name"
	type        = string
	default     = "d2-2"
}

variable "image_name" {
	description = "Image name used to create the instance"
	type        = string
	default     = "Debian 12"
}

variable "ssh_allowed_cidr" {
	description = "CIDR allowed to SSH to instance"
	type        = string
	default     = "0.0.0.0/0"
}
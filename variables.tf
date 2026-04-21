variable "ovh_application_key" {
	description = "OVH API application key"
	type        = string
	sensitive   = true
}

variable "ovh_application_secret" {
	description = "OVH API application secret"
	type        = string
	sensitive   = true
}

variable "ovh_consumer_key" {
	description = "OVH API consumer key"
	type        = string
	sensitive   = true
}

variable "project_id" {
	description = "OVH Public Cloud project ID (service_name)"
	type        = string
}

variable "ssh_key_name" {
	description = "Existing OVH SSH key name"
	type        = string
}

variable "region" {
	description = "OVH region used for network and instance"
	type        = string
	default     = "GRA11"
}

variable "public_network_name" {
	description = "OpenStack public network pool name"
	type        = string
	default     = "Ext-Net"
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

variable "private_network_name" {
	description = "Private network name"
	type        = string
	default     = "vpc-main"
}

variable "private_subnet_cidr" {
	description = "Private subnet CIDR"
	type        = string
	default     = "10.0.1.0/24"
}

variable "private_subnet_start_ip" {
	description = "First DHCP IP in subnet"
	type        = string
	default     = "10.0.1.10"
}

variable "private_subnet_end_ip" {
	description = "Last DHCP IP in subnet"
	type        = string
	default     = "10.0.1.200"
}

variable "security_group_name" {
	description = "Security group name"
	type        = string
	default     = "web-sg"
}

variable "ssh_allowed_cidr" {
	description = "CIDR allowed to SSH to instance"
	type        = string
	default     = "0.0.0.0/0"
}
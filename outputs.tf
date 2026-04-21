output "instance_id" {
  description = "ID of the created OVH instance"
  value       = openstack_compute_instance_v2.vm.id
}

output "instance_name" {
  description = "Name of the created OVH instance"
  value       = openstack_compute_instance_v2.vm.name
}

output "instance_public_ip" {
  description = "Public IP attached to the OVH instance"
  value       = openstack_networking_floatingip_v2.ip.address
}

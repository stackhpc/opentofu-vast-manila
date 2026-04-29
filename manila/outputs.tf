output "cidr" {
  value = openstack_networking_subnet_v2.manila_test.cidr
}

output "allocation_pool" {
  value = openstack_networking_subnet_v2.manila_test.allocation_pool
}

output "vlan" {
  value = openstack_networking_network_v2.manila_test.segments
}

output project_id {
  value = openstack_identity_project_v3.manila_test.id
}

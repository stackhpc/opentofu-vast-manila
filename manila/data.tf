data "openstack_identity_user_v3" "admin" {
  name = "admin"
}

data "openstack_identity_role_v3" "member" {
  name = "member"
}

data "openstack_networking_subnetpool_v2" "project_nets" {
  name = "project_nets"
}

data "openstack_networking_network_v2" "external" {
  name = "public"
}
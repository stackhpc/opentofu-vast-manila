# assuming tenant networks are vlan type by default
# and make azimuth pick this one up
resource "openstack_networking_network_v2" "manila_test" {
  tenant_id = openstack_identity_project_v3.manila_test.id
  name           = "portal-internal"
  admin_state_up = "true"
  tags = ["portal-internal"]
}

resource "openstack_networking_subnet_v2" "manila_test" {
  tenant_id = openstack_identity_project_v3.manila_test.id
  name = "manila_test"
  network_id = openstack_networking_network_v2.manila_test.id
  subnetpool_id = data.openstack_networking_subnetpool_v2.project_nets.id
  # TODO: this needs updating after the above pool picks the cidr
  # but we need to shrink it for vast to work
  allocation_pool {
    end = "192.168.4.149"
    start = "192.168.4.2"
  }
}

resource "openstack_networking_router_v2" "manila_test" {
  tenant_id = openstack_identity_project_v3.manila_test.id
  name                = "manila_test"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.manila_test.id
  subnet_id = openstack_networking_subnet_v2.manila_test.id
}

resource "openstack_networking_network_v2" "manila_test_ib" {
  tenant_id = openstack_identity_project_v3.manila_test.id
  name           = "portal-internal-ib"
  admin_state_up = "true"
  segments {
    physical_network = "ibphysnet"
    network_type = "vlan"
    segmentation_id = var.ib_pkey
  }
  tags = ["portal-storage"]
}

# Only needs to not overlap with portal internal
resource "openstack_networking_subnet_v2" "manila_test_ib" {
  tenant_id = openstack_identity_project_v3.manila_test.id
  name = "manila_test_ib"
  network_id = openstack_networking_network_v2.manila_test_ib.id
  subnetpool_id = data.openstack_networking_subnetpool_v2.project_nets.id
  no_gateway = true
}

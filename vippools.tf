module "vast" {
  source = "github.com/stackhpc/openstack-tofu-manila?ref=main"

  vippools = {
    "openstack_vlan_1146" = {
      vlan = "1146"
      role = "PROTOCOLS"
      subnet_cidr = "24"
      ip_ranges = [
        ["192.168.4.200", "192.168.4.249"],
      ]
    }
    "openstack_vlan_1024 = {
      vlan = "1024"
      role = "PROTOCOLS"
      subnet_cidr = "24"
      ip_ranges = [
        ["192.168.9.200", "192.168.9.249"],
      ]
    }
    "openstack_vlan_1038 = {
      vlan = "1038"
      role = "PROTOCOLS"
      subnet_cidr = "24"
      ip_ranges = [
        ["192.168.11.200", "192.168.11.249"],
      ]
    }
    "openstack_vlan_1073 = {
      vlan = "1024"
      role = "PROTOCOLS"
      subnet_cidr = "24"
      ip_ranges = [
        ["192.168.10.200", "192.168.10.249"],
      ]
    }
  }
}
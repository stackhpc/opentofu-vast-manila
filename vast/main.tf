variable "password" {
  sensitive = true
}

variable "vast_host" {
  default = "10.3.2.10"
}

terraform {
  required_providers {
    vastdata = {
      source = "vast-data/vastdata"
      version = "2.1.1"
    }
  }
}

provider "vastdata" {
  username        = "openstack-manila"
  port            = 443
  password        = var.password
  host            = var.vast_host
  skip_ssl_verify = true
}

resource "vastdata_vip_pool" "openstack_vlan_1146" {
  name                      = "openstack_vlan_1146"
  vlan = 1146
  role = "PROTOCOLS"
  subnet_cidr = "24"
  # enable_weighted_balancing = true
  ip_ranges = [
    ["192.168.4.200", "192.168.4.249"],
  ]
}

# need vast config updated with share type, then do something like:
# openstack share type create vast_1146 false --snapshot-support=true --extra-specs share_backend_name=VAST_1146 --public false
# openstack share type access create vast_1146 `openstack project show manila_test -f value -c id`
# openstack share type access list vast_1146
#
# check for service with share type:
# openstack share service list

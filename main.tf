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

resource "vastdata_vip_pool" "vippool" {
  for_each = var.vippools

  name = each.key
  vlan = lookup(each.value, "vlan", null)
  role = lookup(each.value, "role", null)
  subnet_cidr = lookup(each.value, "subnet_cidr", null)
  ip_ranges = lookup(each.value, "ip_ranges", [])
}

# need vast config updated with share type, then do something like:
# openstack share type create vast_1146 false --snapshot-support=true --extra-specs share_backend_name=VAST_1146 --public false
# openstack share type access create vast_1146 `openstack project show manila_test -f value -c id`
# openstack share type access list vast_1146
#
# check for service with share type:
# openstack share service list

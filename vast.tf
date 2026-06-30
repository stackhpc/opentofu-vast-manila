variable "password" {
  sensitive = true
}

variable "vast_host" {
  default = "10.3.2.10"
}

variable "username" {
  default = "openstack-manila"
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
  username        = var.username
  port            = 443
  password        = var.password
  host            = var.vast_host
  skip_ssl_verify = true
}

resource "vastdata_vip_pool" "vippool" {
  for_each = var.vippools

  name        = each.value.name != null ? (each.value.name) : (each.value.network != null ? format("openstack_vlan_%04d",
    one(var.networks[each.value.network].segments).segmentation_id)
    : each.key)
  vlan        = each.value.vlan != null ? (each.value.vlan) : (one(var.networks[each.value.network].segments).segmentation_id)
  role        = lookup(each.value, "role", null)
  subnet_cidr = lookup(each.value, "subnet_cidr", null)
  tenant_id   = (each.value.project != null ? var.projects[each.value.project].id : each.value.tenant_id)
  ip_ranges   = each.value.ip_ranges != null ? (each.value.ip_ranges) : [
    for r in each.value.vip_ranges : [
      cidrhost(var.subnets[r.subnet].cidr, r.start),
      cidrhost(var.subnets[r.subnet].cidr, r.end)
    ]
  ]
}

resource "vastdata_tenant" "vast_tenant" {
  for_each = var.vast_tenants

  name                 = each.key
  allow_locked_users   = lookup(each.value, "allow_locked_users", null)
  allow_disabled_users = lookup(each.value, "allow_disabled_users", null)
  client_ip_ranges     = each.value.client_ip_ranges != null ? (each.value.client_ip_ranges) : [
    for p in each.value.client_ranges : [
      cidrhost(var.subnets[p.subnet].cidr, p.start),
      cidrhost(var.subnets[p.subnet].cidr, p.end)
    ]
  ]
}

# need vast config updated with share type, then do something like:
# openstack share type create vast_1146 false --snapshot-support=true --extra-specs share_backend_name=VAST_1146 --public false
# openstack share type access create vast_1146 `openstack project show manila_test -f value -c id`
# openstack share type access list vast_1146
#
# check for service with share type:
# openstack share service list

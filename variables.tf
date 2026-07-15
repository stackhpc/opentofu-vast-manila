variable "vippools" {
  description = <<-EOT
    Map of vippools. Key is tofu resource name. Values are mappings with keys/values:
      name: Optional string, if not provided network is used to template name of format "openstack_vlan_<segmentation_id>"
      network: Optional string, tofu network resource name, used to template name and vlan if provided (using segmentation_id)
      vlan: Optional number
      role: Optional string
      subnet_cidr: Optional number
      tenant_id: Optional string, overridden by project
      project: Optional string, openstack project name, overrides tenant_id
      vip_ranges: Optional list. Elements are maps with keys/values.
        subnet: Required string, tofu subnet resource name
        start: Required number
        end: Required number
      ip_ranges: Optional list. Elements are maps with keys/values.
  EOT
  type = map(
    object({
      name                  = optional(string)
      network               = optional(string)
      vlan                  = optional(number)
      role                  = optional(string)
      subnet_cidr           = optional(number)
      tenant_id             = optional(string)
      project               = optional(string)
      # may need renaming
      vip_ranges            = optional(list(object({
        subnet = string
        start  = number
        end    = number
      })), [])
      ip_ranges             = optional(list(list(string)), [])
    })
  )
  default = {}
}

variable "vast_tenants" {
  description = <<-EOT
    Map of vast tenants. Key is tofu resource name. Values are mappings with keys/values:
      allow_locked_users: Optional bool
      allow_disabled_users: Optional bool
      client_ranges: Optional list, overridden by client_ip_ranges
        subnet: Required string, tofu subnet resource name
        start: Required number
        end: Required number
      client_ip_ranges: Optional list, overrides client_ip_ranges
  EOT
  type = map(
    object({
      allow_locked_users   = optional(bool, null)
      allow_disabled_users = optional(bool, null)
      # may need renaming
      client_ranges        = optional(list(object({
        subnet = string
        start  = number
        end    = number
      })), [])
      client_ip_ranges     = optional(list(list(string)), [])
    })
  )
  default = {}
}

variable "password" {
  sensitive = true
}

variable "vast_host" {
  default = "10.3.2.10"
}

variable "username" {
  default = "openstack-manila"
}

variable "subnets" {
  type = map(object({
    id         = string
    gateway_ip = optional(string)
    cidr       = optional(string)
  }))
  default = {}
}

variable "projects" {
  type = map(object({
    id = string
  }))
  default = {}
}

variable "networks" {
  type = map(object({
    id       = string
    segments = list(object({
      segmentation_id = optional(number)
    }))
  }))
  default = {}
}

output "vippools" {
  value = {
    for k, v in vastdata_vip_pool.vippool :
    k => {
      name = v.name
    }
  }
}

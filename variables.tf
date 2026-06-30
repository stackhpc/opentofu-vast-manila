variable "vippools" {
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
  type = map(
    object({
      name                 = string
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

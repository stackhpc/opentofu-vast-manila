variable "vippools" {
  type = map(
    object({
      vlan                  = optional(number)
      role                  = optional(string)
      subnet_cidr           = optional(number)
      ip_ranges = optional(list(list(string)), [])
    })
  )
  default = {}
}
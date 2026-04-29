terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "3.3.2"
    }
  }
}

provider "openstack" {
  # Configuration options
  cloud = "6gai_admin"
}

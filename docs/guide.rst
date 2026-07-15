===============================
OpenTofu Vast Manila User Guide
===============================

OpenTofu Vast Manila allows you to manage your Vast resources using Terraform.
This guide will provide you with example templated for available resources.
A full list of variables available for each resource can be found in `variables.tf`_
with a description and type.

Currently, this module requires `Tofu OpenStack Config`_ support for networks,
subnets and project. See `integration section`_ for more details.

It is recommend for easy readibility to separate your resources in ``main.tf``
as follows:

.. code-block:: console

    module "vast" {
        source =

        # vast credentials need to be accessible to the module
        username =
        password =

        vippools     = local.vippool-config
        vast_tenants = local.vast-tenant-config
        ...
    }

The config for each resource can then be written into separate files, suggested
format is ``<resource>-config.tf``, for example:

- ``vippool-config.tf``
- ``vast-tenant-config.tf``

Vippools
--------

To create a vippool, add config to ``vippool-config.tf``.

Template:

.. code-block:: console

    locals {
        vippool-config = {
            ## start of template
            "<your-tofu-vippool-name" = {
                name        = # optional, if network provided name is templated from given network segmetation_id for format openstack_vlan_<segmentation_id>
                subnet_cidr =
                network     = "<your-tofu-network-name>"
                project     =

                vip_ranges = [
                    { subnet =
                      start  =
                      end    =
                    }, # vip_ranges must be separated by a comma (,)
                    { ... }
                ]
            }
            ## end of template
        }
    }

Vast Tenants
------------

To create a Vast tenant, add config to ``vast-tenant-config``.

Template:

.. code-block:: console

    locals {
        vast-tenant-config = {
            ## start of template
            "<your-vast-tenant-name>" = {
                allow_locked_users =
                allow_disabled_users =

                client_ranges = [
                    {
                        subnet = "<tofu-subnet-name>"
                        start =
                        end =
                    }, #client_ranges must be separated by a comma (,)
                    { ... }
                ]
                # or
                client_ip_ranges = [
                    { ... }, #client_ip_ranges must be separated by a comma (,)
                    { ... }
                ]
            }
            ## end of template
        }
    }


.. _integration section:

==================================
Tofu OpenStack Config Integration
==================================

To access the ``projects``, ``networks`` and ``subnets`` resources from `Tofu OpenStack Config`_
module, you need to provide the ``vast`` mpdule with the ``openstack`` resources.
This can be done by including the following in your ``main.tf``:

.. code-block:: console

    ##main.tf
    module "vast" {
        source = "github.com/stackhpc/opentofu-vast-manila?ref=main"
        # this lines takes the resources from the module "openstack" into the vast module
        projects = module.openstack.projects
        networks = module.openstack.networks
        subnets  = module.openstack.subnets
        ...
    }

    module "openstack" {
        source = "github.com/stackhpc/tofu-openstack-config?ref=main"

        projects =
        networks =
        subnets  =
        ...
    }

.. _variables.tf: https://github.com/stackhpc/opentofu-vast-manila/blob/main/variables.tf
.. _Tofu OpenStack Config: https://github.com/stackhpc/tofu-openstack-config
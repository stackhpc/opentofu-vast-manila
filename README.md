# VAST with Manila CSI

Each OpenStack project gets an IB network and an ethernet network.
Subnet pool is used to ensure no project networks overlap.
Networks are tagged with portal-internal and portal-storage.

We have some example tofu to deploy a project in this way,
as an example.

VAST VIP pool is created using part of the tenant network CIDR.
We have some tofu that can create that VIP pool in VAST.
VAST gets one (private) share type per project.
Manila config updated with share backend that maps to VAST VIP pool.
Note that no two share types can have the same name.
Question: could manila share networks be used to model this instead?

We have the ability to configure VAST cinder and manila in this
kolla-ansible branch:
https://github.com/stackhpc/kolla-ansible/tree/feature/vast-on-epoxy

The manila config looks like:

    [DEFAULT]
    enabled_share_backends = vast_vlan_1123,vast_vlan_1124

    {% raw %}
    [vast_vlan_1123]
    share_backend_name = vast_vlan_1123
    share_driver = manila.share.drivers.vastdata.driver.VASTShareDriver
    snapshot_support = true
    driver_handles_share_servers = false
    vast_mgmt_host = {{ manila_vast_mgmt_host }}
    vast_mgmt_user = {{ manila_vast_mgmt_user }}
    vast_mgmt_password = {{ manila_vast_mgmt_password }}
    vast_root_export = {{ manila_vast_root_export | default("manila") }}
    vast_vippool_name = openstack_vlan_1123
    {% endraw %}

To create the matching share type you do something like this:

    openstack share type create vast_1121 false \
        --snapshot-support=true --extra-specs
        share_backend_name=vast_vlan_1123 --public false
    project_id=`openstack project show manila_test -f value -c id`
    openstack share type access create vast_1121 $project_id
    openstack share type access list vast_1121

capi-helm charts do not currently install the NFS CSI.
You can do that like this::

    helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
    helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1

More details on NFS CSI here:
https://github.com/kubernetes-csi/csi-driver-nfs/tree/9c782919ec6b08d4b0991cbeb060567fe6722cdf/charts

Once this is installed, you can use Manila CSI by modifying
the Azimuth template something like this:

    addons:
      openstack:
        csiCinder:
          enabled: true
        defaultStorageClass:
          enabled: true
          # need a default for monitoring pods
          isClusterDefault: true
        csiManila:
          enabled: true
          provisioner: nfs.manila.csi.openstack.org
          defaultStorageClass:
            enabled: false
            isClusterDefault: false
            parameters:
              # TODO: this is per openstack project
              type: vast_todo

The above skips adding the k8s storage class, as it
need to have the project specific manila share type
specified in there.
We have an example of a pvc in storageclass.yaml.
Note: it seems there is no way to add nconnect
into the nfs params, this way.
Note: by default it adds an access rule for 0.0.0.0/0
that creates big problems, do not forget the correct CIDR.

If we create a manila share, we could also directly
mount that with NFS, and specify things like nconnect
via the NFS CSI directly, as need in nfs.yaml.
Note that NFSv4 protocol isn't added by Manila.

Note there were some other bugs that need resolving:

* os-region in manila creds is required but was missing
* NFS CSI was not installed, but is required

When debugging, note the useful logs are not in the default
nfs csi container. If VAST is missing the tenant VLAN you
will see errors something like this:

    kubectl logs -n kube-system csi-nfs-node-bsszr nfs
    ...
    GRPC call: /csi.v1.Node/NodePublishVolume
    ...
    No route to host.
    ...
    (no route to host only first time, future errors
    talk about missing mount directory)
    ...
    <fix switch>
    ...
    I1117 11:58:34.931957       1 nodeserver.go:155] volume(494cc53c-eb82-4803-ba68-a4965dfebdf8) mount 192.168.4.200:/manila/manila-090fe082-9006-446a-a8ce-822997810d85 on /var/lib/kubelet/pods/fccd5c2e-0668-4b42-b504-ed4aa367837b/volumes/kubernetes.io~csi/pvc-83234964-efb7-4f27-bb2f-d7558cdb90f8/mount succeeded
    I1117 11:58:34.931979       1 utils.go:118] GRPC response: {}

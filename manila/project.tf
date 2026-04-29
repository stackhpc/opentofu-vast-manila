resource "openstack_identity_project_v3" "manila_test" {
  name        = "manila_test"
  description = "A project"
}

resource "openstack_identity_role_assignment_v3" "role_assignment_admin" {
  user_id    = data.openstack_identity_user_v3.admin.id
  project_id = openstack_identity_project_v3.manila_test.id
  role_id    = data.openstack_identity_role_v3.member.id
}

resource "openstack_compute_quotaset_v2" "manila_test" {
  project_id           = openstack_identity_project_v3.manila_test.id
  ram                  = 409600
  cores                = 320
  instances            = 20
}

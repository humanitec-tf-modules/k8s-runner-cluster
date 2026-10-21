# Mock all providers so the tests run without access to a Kubernetes cluster
mock_provider "kubernetes" {}

run "defaults" {
  command = plan

  # Namespace
  assert {
    condition     = output.runner_namespace == "humanitec-runner"
    error_message = "Output runner_namespace should default to \"humanitec-runner\""
  }

  # Service account
  assert {
    condition     = kubernetes_service_account_v1.runner.metadata[0].namespace == "humanitec-runner"
    error_message = "Service account should be placed in the runner namespace"
  }
  assert {
    condition     = length(coalesce(output.runner_serviceaccount_annotations, {})) == 0
    error_message = "Output runner_serviceaccount_annotations should be empty by default"
  }
  assert {
    condition     = output.runner_serviceaccount_name == "humanitec-runner"
    error_message = "Output runner_serviceaccount_name should default to \"humanitec-runner\""
  }

  # Role with basic permissions only
  assert {
    condition     = kubernetes_role_v1.runner.metadata[0].namespace == "humanitec-runner"
    error_message = "Role should be placed in the runner namespace"
  }
  assert {
    condition     = length(kubernetes_role_v1.runner.rule) == 1
    error_message = "Role should have exactly one rule when the kubernetes backend is not supported"
  }
  assert {
    condition     = output.runner_role_name == "humanitec-runner"
    error_message = "Output runner_role_name should default to \"humanitec-runner\""
  }

  # Role binding
  assert {
    condition     = kubernetes_role_binding_v1.runner.role_ref[0].name == "humanitec-runner"
    error_message = "Role binding should reference the runner role"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner.subject[0].kind == "ServiceAccount" &&
      kubernetes_role_binding_v1.runner.subject[0].name == "humanitec-runner" &&
      kubernetes_role_binding_v1.runner.subject[0].namespace == "humanitec-runner"
    )
    error_message = "Role binding should bind the runner service account"
  }
  assert {
    condition     = output.runner_rolebinding_name == "humanitec-runner"
    error_message = "Output runner_rolebinding_name should default to \"humanitec-runner\""
  }

  # No separate runner cluster resources
  assert {
    condition     = output.separate_runner_cluster_role_name == null
    error_message = "Output separate_runner_cluster_role_name should be null by default"
  }
  assert {
    condition     = output.separate_runner_cluster_rolebinding_name == null
    error_message = "Output separate_runner_cluster_rolebinding_name should be null by default"
  }
  assert {
    condition     = output.separate_runner_cluster_rolebinding_subjects == null
    error_message = "Output separate_runner_cluster_rolebinding_subjects should be null by default"
  }
}

run "all_variables_set" {
  command = plan

  variables {
    runner_namespace      = "my-namespace"
    runner_serviceaccount = "my-serviceaccount"
    runner_serviceaccount_annotations = {
      "iam.gke.io/gcp-service-account" = "runner@my-project.iam.gserviceaccount.com"
      "example.com/team"               = "platform"
    }
    runner_role                   = "my-role"
    support_kubernetes_tf_backend = true
    is_separate_runner_cluster    = true
    separate_runner_cluster_subjects = [
      {
        kind      = "ServiceAccount"
        name      = "my-serviceaccount"
        namespace = "my-namespace"
      },
      {
        kind      = "Group"
        name      = "my-group"
        api_group = "rbac.authorization.k8s.io"
      },
      {
        kind = "User"
        name = "my-user"
      },
    ]
  }

  # Namespace
  assert {
    condition     = output.runner_namespace == "my-namespace"
    error_message = "Output runner_namespace should be taken from runner_namespace"
  }

  # Service account
  assert {
    condition     = kubernetes_service_account_v1.runner.metadata[0].namespace == "my-namespace"
    error_message = "Service account should be placed in the runner namespace"
  }
  assert {
    condition = output.runner_serviceaccount_annotations == tomap({
      "iam.gke.io/gcp-service-account" = "runner@my-project.iam.gserviceaccount.com"
      "example.com/team"               = "platform"
    })
    error_message = "Output runner_serviceaccount_annotations should be taken from runner_serviceaccount_annotations"
  }
  assert {
    condition     = output.runner_serviceaccount_name == "my-serviceaccount"
    error_message = "Output runner_serviceaccount_name should be taken from runner_serviceaccount"
  }

  # Role with extended permissions for the kubernetes backend
  assert {
    condition     = kubernetes_role_v1.runner.metadata[0].namespace == "my-namespace"
    error_message = "Role should be placed in the runner namespace"
  }
  assert {
    condition     = length(kubernetes_role_v1.runner.rule) == 3
    error_message = "Role should have three rules when the kubernetes backend is supported"
  }
  assert {
    condition     = output.runner_role_name == "my-role"
    error_message = "Output runner_role_name should be taken from runner_role"
  }

  # Role binding
  assert {
    condition     = kubernetes_role_binding_v1.runner.metadata[0].namespace == "my-namespace"
    error_message = "Role binding should be placed in the runner namespace"
  }
  assert {
    condition     = kubernetes_role_binding_v1.runner.role_ref[0].name == "my-role"
    error_message = "Role binding should reference the runner role"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner.subject[0].kind == "ServiceAccount" &&
      kubernetes_role_binding_v1.runner.subject[0].name == "my-serviceaccount" &&
      kubernetes_role_binding_v1.runner.subject[0].namespace == "my-namespace"
    )
    error_message = "Role binding should bind the runner service account"
  }
  assert {
    condition     = output.runner_rolebinding_name == "my-role"
    error_message = "Output runner_rolebinding_name should be taken from runner_role"
  }

  # Separate runner cluster role
  assert {
    condition     = length(kubernetes_role_v1.runner_separate) == 1
    error_message = "A separate runner cluster role should be created"
  }
  assert {
    condition     = kubernetes_role_v1.runner_separate[0].metadata[0].namespace == "my-namespace"
    error_message = "Separate runner cluster role should be placed in the runner namespace"
  }
  assert {
    condition     = length(kubernetes_role_v1.runner_separate[0].rule) == 4
    error_message = "Separate runner cluster role should have four rules"
  }
  assert {
    condition     = output.separate_runner_cluster_role_name == "my-role-jobs"
    error_message = "Output separate_runner_cluster_role_name should be \"<runner_role>-jobs\""
  }

  # Separate runner cluster role binding
  assert {
    condition     = length(kubernetes_role_binding_v1.runner_separate) == 1
    error_message = "A separate runner cluster role binding should be created"
  }
  assert {
    condition     = kubernetes_role_binding_v1.runner_separate[0].role_ref[0].name == "my-role-jobs"
    error_message = "Separate runner cluster role binding should reference the separate runner cluster role"
  }
  assert {
    condition     = length(kubernetes_role_binding_v1.runner_separate[0].subject) == 3
    error_message = "Separate runner cluster role binding should have one subject per entry in separate_runner_cluster_subjects"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner_separate[0].subject[0].kind == "ServiceAccount" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[0].name == "my-serviceaccount" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[0].namespace == "my-namespace"
    )
    error_message = "Separate runner cluster role binding should bind the first subject from separate_runner_cluster_subjects"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner_separate[0].subject[1].kind == "Group" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[1].name == "my-group" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[1].api_group == "rbac.authorization.k8s.io" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[1].namespace == null
    )
    error_message = "Separate runner cluster role binding should bind the second subject from separate_runner_cluster_subjects"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner_separate[0].subject[2].kind == "User" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[2].name == "my-user" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[2].namespace == null
    )
    error_message = "Separate runner cluster role binding should bind the third subject from separate_runner_cluster_subjects"
  }
  assert {
    condition     = output.separate_runner_cluster_rolebinding_name == "my-role-jobs"
    error_message = "Output separate_runner_cluster_rolebinding_name should be \"<runner_role>-jobs\""
  }
  assert {
    condition = (
      length(output.separate_runner_cluster_rolebinding_subjects) == 3 &&
      output.separate_runner_cluster_rolebinding_subjects[0].kind == "ServiceAccount" &&
      output.separate_runner_cluster_rolebinding_subjects[0].name == "my-serviceaccount" &&
      output.separate_runner_cluster_rolebinding_subjects[0].namespace == "my-namespace" &&
      output.separate_runner_cluster_rolebinding_subjects[1].kind == "Group" &&
      output.separate_runner_cluster_rolebinding_subjects[1].name == "my-group" &&
      output.separate_runner_cluster_rolebinding_subjects[1].api_group == "rbac.authorization.k8s.io" &&
      output.separate_runner_cluster_rolebinding_subjects[2].kind == "User" &&
      output.separate_runner_cluster_rolebinding_subjects[2].name == "my-user"
    )
    error_message = "Output separate_runner_cluster_rolebinding_subjects should contain the subjects from separate_runner_cluster_subjects"
  }
}

run "separate_runner_cluster_requires_subjects" {
  command = plan

  variables {
    is_separate_runner_cluster = true
  }

  expect_failures = [
    var.separate_runner_cluster_subjects,
  ]
}

run "separate_runner_cluster_subject_optional_attributes" {
  command = plan

  variables {
    is_separate_runner_cluster = true
    separate_runner_cluster_subjects = [
      {
        kind = "User"
        name = "my-user"
      },
    ]
  }

  assert {
    condition     = length(kubernetes_role_binding_v1.runner_separate[0].subject) == 1
    error_message = "Separate runner cluster role binding should have exactly one subject"
  }
  assert {
    condition = (
      kubernetes_role_binding_v1.runner_separate[0].subject[0].kind == "User" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[0].name == "my-user" &&
      kubernetes_role_binding_v1.runner_separate[0].subject[0].namespace == null
    )
    error_message = "Separate runner cluster role binding should bind the subject from separate_runner_cluster_subjects"
  }
}

run "subjects_ignored_without_separate_runner_cluster" {
  command = plan

  variables {
    separate_runner_cluster_subjects = [
      {
        kind = "User"
        name = "my-user"
      },
    ]
  }

  assert {
    condition     = length(kubernetes_role_binding_v1.runner_separate) == 0
    error_message = "No separate runner cluster role binding should be created if is_separate_runner_cluster is false"
  }
}

run "separate_runner_cluster_rolebinding_subjects_output_after_apply" {
  # Apply against the mocked provider so that computed subject attributes are filled in
  command = apply

  variables {
    is_separate_runner_cluster = true
    separate_runner_cluster_subjects = [
      {
        kind = "User"
        name = "my-user"
      },
    ]
  }

  assert {
    condition     = length(output.separate_runner_cluster_rolebinding_subjects) == 1
    error_message = "Output separate_runner_cluster_rolebinding_subjects should contain exactly one subject"
  }
  assert {
    condition = (
      output.separate_runner_cluster_rolebinding_subjects[0].kind == "User" &&
      output.separate_runner_cluster_rolebinding_subjects[0].name == "my-user" &&
      output.separate_runner_cluster_rolebinding_subjects[0].namespace == null
    )
    error_message = "Output separate_runner_cluster_rolebinding_subjects should contain the subject from separate_runner_cluster_subjects"
  }
  assert {
    condition     = output.separate_runner_cluster_rolebinding_subjects[0].api_group != null
    error_message = "Output separate_runner_cluster_rolebinding_subjects should contain the api_group filled in by the provider"
  }
}

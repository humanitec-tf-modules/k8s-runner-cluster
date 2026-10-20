resource "kubernetes_namespace_v1" "runner" {
  metadata {
    name = var.runner_namespace
  }
}

resource "kubernetes_service_account_v1" "runner" {
  metadata {
    name        = var.runner_serviceaccount
    namespace   = kubernetes_namespace_v1.runner.metadata[0].name
    annotations = var.runner_serviceaccount_annotations
  }
}

locals {
  runner_role_rules = var.support_kubernetes_tf_backend ? [
    # Permissions when a `kubernetes` OpenTofu/Terraform backend is used
    {
      api_groups = [""]
      resources  = ["configmaps"]
      verbs      = ["create"]
    },
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["create", "get", "delete", "list", "update", "deletecollection"]
    },
    {
      api_groups = ["coordination.k8s.io"]
      resources  = ["leases"]
      verbs      = ["create", "get", "list", "update", "watch"]
    },
    ] : [
    # Basic permissions when no `kubernetes` backend is used
    {
      api_groups = [""]
      resources  = ["secrets", "configmaps"]
      verbs      = ["create"]
    },
  ]
}

# This role covers the permissions for the K8s service account.
# The rules depend on whether support for a `kubernetes` OpenTofu/Terraform backend is required
resource "kubernetes_role_v1" "runner" {
  metadata {
    name      = var.runner_role
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }

  dynamic "rule" {
    for_each = local.runner_role_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}
# Bind the role to the service account
resource "kubernetes_role_binding_v1" "runner" {
  metadata {
    name      = kubernetes_role_v1.runner.metadata[0].name
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.runner.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.runner.metadata[0].name
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }
}

# This role covers additional permissions required when the target cluster is a separate runner cluster
resource "kubernetes_role_v1" "runner_separate" {
  count = var.is_separate_runner_cluster ? 1 : 0
  metadata {
    name      = "${var.runner_role}-jobs"
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["create", "delete", "deletecollection", "get"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "events"]
    verbs      = ["list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
}
# Bind the role to the service account
resource "kubernetes_role_binding_v1" "runner_separate" {
  count = var.is_separate_runner_cluster ? 1 : 0
  metadata {
    name      = kubernetes_role_v1.runner_separate[0].metadata[0].name
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.runner_separate[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.runner.metadata[0].name
    namespace = kubernetes_namespace_v1.runner.metadata[0].name
  }
}

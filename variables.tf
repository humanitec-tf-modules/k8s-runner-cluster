variable "runner_namespace" {
  description = "Name of the Kubernetes namespacefor the runner."
  type        = string
  nullable    = false
  default     = "humanitec-runner"
}
variable "runner_serviceaccount" {
  description = "Name of the Kubernetes service account for the runner."
  type        = string
  nullable    = false
  default     = "humanitec-runner"
}
variable "runner_serviceaccount_annotations" {
  description = "Annotations to add to the runner Kubernetes service account."
  type        = map(string)
  nullable    = false
  default     = {}
}
variable "runner_role" {
  description = "Name of the Kubernetes role for the runner"
  type        = string
  nullable    = false
  default     = "humanitec-runner"
}
variable "support_kubernetes_tf_backend" {
  description = "Whether to support a `kubernetes` OpenTofu/Terraform backend for the runner. Setting this to `true` adds extended permissions to the role for the runner service account. If not required, leave it at `false` to maintain least privilege."
  type        = bool
  nullable    = false
  default     = false
}
variable "is_separate_runner_cluster" {
  description = "Whether the target cluster is a separate runner cluster, i.e. not on the same cluster as an Operator. Setting this to `true` results in an additional role created for managing Kubernetes Jobs and related resources, bound to the subjects in `separate_runner_cluster_subjects`."
  type        = bool
  nullable    = false
  default     = false
}
variable "separate_runner_cluster_subjects" {
  description = "Subjects to bind to the additional role created if `is_separate_runner_cluster` is `true`. These are the identities accessing the separate runner cluster, which depend on the technology used for that kind of access. Required to contain at least one subject if `is_separate_runner_cluster` is `true`. `namespace` is required for subjects of kind `ServiceAccount`. For other kinds it has no effect, but note that the Kubernetes provider still sets it to `default` on the created RoleBinding."
  type = list(object({
    kind      = string
    name      = string
    api_group = optional(string)
    namespace = optional(string)
  }))
  nullable = false
  default  = []

  validation {
    condition     = !var.is_separate_runner_cluster || length(var.separate_runner_cluster_subjects) > 0
    error_message = "separate_runner_cluster_subjects must contain at least one subject if is_separate_runner_cluster is true."
  }

  validation {
    condition = alltrue([
      for s in var.separate_runner_cluster_subjects : s.kind != "ServiceAccount" || try(length(s.namespace) > 0, false)
    ])
    error_message = "separate_runner_cluster_subjects entries of kind ServiceAccount must set namespace."
  }
}

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
  description = "Whether the target cluster is a separate runner cluster, i.e. not on the same cluster as an Operator. Setting this to `true` results in an additional role created and bound to the runner service account for managing Kubernetes Jobs and related resources."
  type        = bool
  nullable    = false
  default     = false
}

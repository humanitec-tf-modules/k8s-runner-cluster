output "runner_namespace" {
  description = "Name of the Kubernetes namespace for the runner."
  value       = kubernetes_namespace_v1.runner.metadata[0].name
}
output "runner_serviceaccount_name" {
  description = "Name of the Kubernetes service account for the runner."
  value       = kubernetes_service_account_v1.runner.metadata[0].name
}
output "runner_serviceaccount_annotations" {
  description = "Annotations of the Kubernetes service account"
  value       = kubernetes_service_account_v1.runner.metadata[0].annotations
}
output "runner_role_name" {
  description = "Name of the Kubernetes role for the runner."
  value       = kubernetes_role_v1.runner.metadata[0].name
}
output "runner_rolebinding_name" {
  description = "Name of the Kubernetes rolebinding for the runner."
  value       = kubernetes_role_binding_v1.runner.metadata[0].name
}
output "separate_runner_cluster_role_name" {
  description = "Name of the Kubernetes role created if `is_separate_runner_cluster` is `true`. Returns `null` otherwise."
  value       = one(kubernetes_role_v1.runner_separate[*].metadata[0].name)
}
output "separate_runner_cluster_rolebinding_name" {
  description = "Name of the Kubernetes rolebinding created if `is_separate_runner_cluster` is `true`. Returns `null` otherwise."
  value       = one(kubernetes_role_binding_v1.runner_separate[*].metadata[0].name)
}
output "separate_runner_cluster_rolebinding_subjects" {
  description = "Subjects of the Kubernetes rolebinding created if `is_separate_runner_cluster` is `true`, including any attributes filled in by the provider. Returns `null` otherwise."
  value       = one(kubernetes_role_binding_v1.runner_separate[*].subject)
}

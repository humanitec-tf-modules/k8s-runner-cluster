# Kubernetes runner cluster

This repository contains an OpenTofu/Terraform module to set up a Kubernetes cluster as a runner cluster for the [Container (builtin)](https://developer.humanitec.com/platform-orchestrator/docs/integration-and-extensions/drivers/container-builtin/) Driver and Drivers based on it such as the [Terraform and OpenTofu Container (builtin)](https://developer.humanitec.com/platform-orchestrator/docs/integration-and-extensions/drivers/terraform-and-opentofu-container-builtin/) Driver.

TODO - call out it does not work for the Terraform runner and others.

TODO - add description and usage examples.

TODO - link to cloud specific wrapper modules that also set up the runner identity.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_role_binding_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_role_binding_v1.runner_separate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_role_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |
| [kubernetes_role_v1.runner_separate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |
| [kubernetes_service_account_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_separate_runner_cluster"></a> [is\_separate\_runner\_cluster](#input\_is\_separate\_runner\_cluster) | Whether the target cluster is a separate runner cluster, i.e. not on the same cluster as an Operator. Setting this to `true` results in an additional role created and bound to the runner service account for managing Kubernetes Jobs and related resources. | `bool` | `false` | no |
| <a name="input_runner_namespace"></a> [runner\_namespace](#input\_runner\_namespace) | Name of the Kubernetes namespacefor the runner. | `string` | `"humanitec-runner"` | no |
| <a name="input_runner_role"></a> [runner\_role](#input\_runner\_role) | Name of the Kubernetes role for the runner | `string` | `"humanitec-runner"` | no |
| <a name="input_runner_serviceaccount"></a> [runner\_serviceaccount](#input\_runner\_serviceaccount) | Name of the Kubernetes service account for the runner. | `string` | `"humanitec-runner"` | no |
| <a name="input_runner_serviceaccount_annotations"></a> [runner\_serviceaccount\_annotations](#input\_runner\_serviceaccount\_annotations) | Annotations to add to the runner Kubernetes service account. | `map(string)` | `{}` | no |
| <a name="input_support_kubernetes_tf_backend"></a> [support\_kubernetes\_tf\_backend](#input\_support\_kubernetes\_tf\_backend) | Whether to support a `kubernetes` OpenTofu/Terraform backend for the runner. Setting this to `true` adds extended permissions to the role for the runner service account. If not required, leave it at `false` to maintain least privilege. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runner_namespace"></a> [runner\_namespace](#output\_runner\_namespace) | Name of the Kubernetes namespace for the runner. |
| <a name="output_runner_role_name"></a> [runner\_role\_name](#output\_runner\_role\_name) | Name of the Kubernetes role for the runner. |
| <a name="output_runner_rolebinding_name"></a> [runner\_rolebinding\_name](#output\_runner\_rolebinding\_name) | Name of the Kubernetes rolebinding for the runner. |
| <a name="output_runner_serviceaccount_name"></a> [runner\_serviceaccount\_name](#output\_runner\_serviceaccount\_name) | Name of the Kubernetes service account for the runner. |
| <a name="output_separate_runner_cluster_role_name"></a> [separate\_runner\_cluster\_role\_name](#output\_separate\_runner\_cluster\_role\_name) | Name of the Kubernetes role created if `is_separate_runner_cluster` is `true`. Returns `null` otherwise. |
| <a name="output_separate_runner_cluster_rolebinding_name"></a> [separate\_runner\_cluster\_rolebinding\_name](#output\_separate\_runner\_cluster\_rolebinding\_name) | Name of the Kubernetes rolebinding created if `is_separate_runner_cluster` is `true`. Returns `null` otherwise. |
<!-- END_TF_DOCS -->

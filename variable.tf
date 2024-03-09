variable "cluster_name" {
  description = "Cluster name which will be used in creation of AWS resources. This should be a user-friendly name that is also unique."
  type        = string
}

variable "otterize_deploy_namespace" {
  description = "The namespace Otterize is deployed in."
  type        = string
  default     = "otterize-system"
}

variable "kubernetes_config_path" {
  type = string
  description = "Path to the kubeconfig file for the cluster you want to deploy Otterize in. Used to read the CA certificate."
  default = "~/.kube/config"
}

variable "cert_manager_trust_anchor_ca_secret_name" {
  type = string
  description = "Name of the secret containing the trust anchor CA used by cert-manager csi-driver-spiffe."
}

variable "cert_manager_namespace" {
  type = string
  description = "Namespace where cert-manager is installed."
}

variable "spiffe_trust_domain" {
  default = "spiffe.cert-manager.io"
}

variable "aws_region" {
  type = string
  description = "AWS region where the AWS account that the Otterize operators will manage resources is in."
}

variable "aws_rolesanywhere_trust_anchor_name" {
  default = "otterize-cert-manager-spiffe"
}
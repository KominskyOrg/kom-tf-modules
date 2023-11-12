variable "vpc_id" {
  type        = string
  description = "The VPC ID of the VPC to be attached to this cluster."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC to be used."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Subent IDs of the subets."
}

variable "sg_id" {
  type        = string
  description = "Security Group ID"
}

variable "pem_name" {
  type        = string
  description = "Name of the pem key that is connected to your AWS account."
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "account_number" {
  type        = string
  description = "AWS account number"
}

variable "oidc_number" {
  type        = string
  description = "The OICD number attached to your cluster."
}

variable "domain_name" {
  type        = string
  description = "The name of your domain. (example.com)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

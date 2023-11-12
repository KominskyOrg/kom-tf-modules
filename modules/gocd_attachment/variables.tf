variable "subdomain_name" {
    type = string
    description = "Subdomain name (ie sudomain.domain)"
}
variable "gocd_server_port" {
    type = number
    description = "Port number the GoCD server will be exposed on."
}
variable "eks_cluster_endpoint" {}
variable "eks_cluster_ca_cert" {}

variable "domain_name" {
  type = string
  description = "The name of your domain. (example.com)"
}

variable "cluster_name" {
  type = string
  description = "Name of the cluster"
}

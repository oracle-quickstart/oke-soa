## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "vcn_id" {}
variable "cluster_name" {}

variable "oke_cluster" {
  default = {
    k8s_version    = "v1.18.10"
    pods_cidr      = "10.1.0.0/16"
    services_cidr  = "10.2.0.0/16"
  }
}
variable "cluster_lb_subnet_ids" {}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = true
}
variable "cluster_options_add_ons_is_tiller_enabled" {
  default = true
}
variable "secrets_encryption_key_ocid" {
  default = null
}
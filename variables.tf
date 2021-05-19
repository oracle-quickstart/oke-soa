## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "ssh_authorized_key" {}

## General inputs

variable "deployment_name" {
  default = "OKE"
}


## Selector to define what to provision
variable "provision_cluster" {
  default = true
}
variable "provision_filesystem" {
  default = true
}
variable "provision_export" {
  default = true
}
variable "provision_database" {
  default = true
}
variable "provision_weblogic_operator" {
  default = true
}
variable "provision_traefik" {
  default = true
}
variable "provision_secrets" {
  default = true
}
variable "provision_soa" {
  default = true
}

## File Storage details
# If file storage is provisioned by this template but the VCN is not, the subnet ocid is required.
variable "fss_subnet_id" {
  default = null
}
# If the cluster is not provisioned by this template, the fss_source_cidr must be specified.
variable "fss_source_cidr" {
  default = "0.0.0.0/0"
}
variable "ad_number" {
  default = 2
}

variable "mount_path" {
  default = "/soa_domains"
}

## Kubernetes Namespaces to use
variable "soa_kubernetes_namespace" {
  default = "soans"
}
variable "weblogic_operator_namespace" {
  default = "opns"
}
variable "ingress_controller_namespace" {
  default = "traefik"
}

## Credentials for Oracle Container Registry
variable "container_registry_email" {}
variable "container_registry_password" {}


## SOA domain details
variable "soa_domain_name" {}
variable "soa_domain_type" {}
variable "soa_domain_admin_username" {}
variable "soa_domain_admin_password" {
  type      = string
  sensitive = true
}

## Schema Database details
variable "jdbc_connection_url" {
  # if provisioned by this template, this should be null, otherwise provide for externally provisioned database
  default = null
}
variable "db_sys_password" {
  type      = string
  sensitive = true
}
variable "rcu_prefix" {
  default = "SOA"
}
variable "rcu_username" {
  default = "rcu"
}
variable "rcu_password" {
  type      = string
  sensitive = true
}

## Database provisioning details
variable "database_name" {}
variable "database_unique_name" {}
variable "pdb_name" {
  default = "pdb"
}
variable "db_system_shape" {
  default = "VM.Standard2.1"
}
variable "db_system_cpu_core_count" {
  default = 1
}
variable "db_system_license_model" {
  default = "LICENSE_INCLUDED"
}
variable "db_system_db_system_options_storage_management" {
  default = "LVM"
}

## VCN details
variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

## OKE cluster details
variable "oke_cluster" {
  default = {
    k8s_version                                             = "v1.19.7"
    pods_cidr                                               = "10.1.0.0/16"
    services_cidr                                           = "10.2.0.0/16"
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = true
    cluster_options_add_ons_is_tiller_enabled               = true
  }
}

variable "node_pools" {
  default = [
    {
      pool_name  = "pool1"
      node_shape = "VM.Standard2.4"
      node_count = 3
      node_labels = {
        "pool_name" = "pool1"
      }
    }
  ]
}

## Optional KMS Key for encrypting File system and Kubernetes secrets at rest
variable "secrets_encryption_key_ocid" {
  default = null
}

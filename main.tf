## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "vcn" {
  source           = "./modules/vcn"
  compartment_ocid = var.compartment_ocid
  vcn_cidr         = var.vcn_cidr
  oke_cluster      = var.oke_cluster
}

module "cluster" {
  source                      = "./modules/k8s"
  cluster_name                = local.cluster_name
  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = var.compartment_ocid
  vcn_id                      = module.vcn.vcn_id
  oke_cluster                 = var.oke_cluster
  cluster_lb_subnet_ids       = [module.vcn.cluster_lb_subnet_id]
  secrets_encryption_key_ocid = var.secrets_encryption_key_ocid
}

module "node_pools" {
  source             = "./modules/node_pool"
  compartment_ocid   = var.compartment_ocid
  cluster_id         = module.cluster.cluster.id
  kubernetes_version = var.oke_cluster.k8s_version
  ssh_authorized_key = var.ssh_authorized_key
  node_pools         = var.node_pools
  nodes_subnet_id    = module.vcn.cluster_nodes_subnet_id
}

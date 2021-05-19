## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "vcn" {
  source             = "./modules/vcn"
  compartment_ocid   = var.compartment_ocid
  vcn_cidr           = var.vcn_cidr
  oke_cluster        = var.oke_cluster
  provision_database = var.provision_database
}

module "database" {
  source                                         = "./modules/database"
  provision_database                             = var.provision_database
  compartment_ocid                               = var.compartment_ocid
  database_name                                  = var.database_name
  database_unique_name                           = var.database_unique_name
  pdb_name                                       = var.pdb_name
  admin_password                                 = var.db_sys_password
  db_system_shape                                = var.db_system_shape
  db_system_cpu_core_count                       = var.db_system_cpu_core_count
  ssh_public_keys                                = [var.ssh_authorized_key]
  subnet_id                                      = module.vcn.database_subnet_id
  db_system_license_model                        = var.db_system_license_model
  db_system_db_system_options_storage_management = var.db_system_db_system_options_storage_management
}

module "cluster" {
  source                      = "./modules/k8s"
  provision_cluster           = var.provision_cluster
  cluster_name                = local.cluster_name
  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = var.compartment_ocid
  vcn_id                      = module.vcn.vcn_id
  oke_cluster                 = var.oke_cluster
  cluster_lb_subnet_ids       = [module.vcn.cluster_lb_subnet_id]
  secrets_encryption_key_ocid = var.secrets_encryption_key_ocid
}

module "node_pools" {
  source              = "./modules/node_pool"
  provision_node_pool = var.provision_cluster
  compartment_ocid    = var.compartment_ocid
  cluster_id          = module.cluster.cluster.id
  kubernetes_version  = var.oke_cluster.k8s_version
  ssh_authorized_key  = var.ssh_authorized_key
  node_pools          = var.node_pools
  nodes_subnet_id     = module.vcn.cluster_nodes_subnet_id
}



module "fss" {
  source               = "./modules/fss"
  provision_filesystem = var.provision_filesystem
  provision_export     = var.provision_export
  compartment_ocid     = var.compartment_ocid
  subnet_id            = var.fss_subnet_id == null ? module.vcn.cluster_nodes_subnet_id : var.fss_subnet_id
  ad_number            = 2
  encryption_key_id    = var.secrets_encryption_key_ocid
  mount_path           = var.mount_path
  source_cidr          = var.provision_cluster == true ? module.vcn.cluster_nodes_subnet_cidr : var.fss_source_cidr
}
## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_file_storage_file_system" "fss" {
  count = var.provision_filesystem ? 1 : 0

  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid

  #Optional
  display_name = "Oracle SOA File System"
  kms_key_id   = var.encryption_key_id
}

resource "oci_file_storage_mount_target" "mount_target" {
  count = var.provision_filesystem ? 1 : 0

  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  subnet_id           = var.subnet_id

  #Optional
  display_name = "Oracle SOA Mount Target"
}

resource "oci_file_storage_export_set" "export_set" {
  count = var.provision_filesystem ? 1 : 0

  #Required
  mount_target_id = oci_file_storage_mount_target.mount_target.0.id

  #Optional
  display_name = "Oracle SOA Export Set for SOA Domains"
}

resource "oci_file_storage_export" "export" {
  #Required
  export_set_id  = oci_file_storage_export_set.export_set.0.id
  file_system_id = oci_file_storage_file_system.fss.0.id
  path           = var.mount_path

  #Optional
  export_options {
    #Required
    source = var.source_cidr

    #Optional
    access                         = "READ_WRITE"
    anonymous_gid                  = null
    anonymous_uid                  = null
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}
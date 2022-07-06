## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "subnet_id" {}
variable "compartment_ocid" {}
variable "ad_number" {
  default = 1
}
variable "encryption_key_id" {
  default = null
}
variable "mount_path" {}
variable "source_cidr" {}
variable "provision_filesystem" {}
variable "provision_export" {}
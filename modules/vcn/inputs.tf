## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Variables passed into vcn module

variable "compartment_ocid" {}

variable "vcn_cidr" {
    default = "10.0.0.0/16"
}
variable "oke_cluster" {}
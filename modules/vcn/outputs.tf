## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Output variables from created vcn

output "vcn_id" {
  value = oci_core_virtual_network.vcn.id
}

output "cluster_lb_subnet_id" {
  value = oci_core_subnet.cluster_lb_subnet.id
}

output "cluster_nodes_subnet_id" {
  value = oci_core_subnet.cluster_nodes_subnet.id
}
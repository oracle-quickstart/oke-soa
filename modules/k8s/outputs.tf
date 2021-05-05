## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "cluster" {
  value = {
    id                 = oci_containerengine_cluster.cluster.id
    kubernetes_version = oci_containerengine_cluster.cluster.kubernetes_version
    name               = oci_containerengine_cluster.cluster.name
  }
}

## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "jdbc_connection_url" {
  value = var.provision_database ? "${oci_database_db_system.db_system.0.hostname}.${oci_database_db_system.db_system.0.domain}:1521/${var.pdb_name}.${oci_database_db_system.db_system.0.domain}" : ""
}

## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# File Storage Server IP address
output "server_ip" {
  value = data.oci_core_private_ip.private_ip.ip_address
}

output "path" {
  value = oci_file_storage_export.export.path
}
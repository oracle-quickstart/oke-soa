## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "kube_config" {
  value = module.cluster.kube_config
}

# output "images" {
#   value = module.node_pools.images
# }

output "jdbc_connection_url" {
  value = module.database.jdbc_connection_url
}


resource "local_file" "helm_values" {
  filename = "./fromtf.auto.yaml"
  content = templatefile("./templates/helm.values.tpl", {
    soa_domain_name     = var.soa_domain_name
    soa_domain_type     = var.soa_domain_type
    soa_domain_secret   = "${var.soa_domain_name}-domain-credentials"
    rcu_prefix          = var.rcu_prefix
    rcu_secret          = "${var.soa_domain_name}-rcu-credentials"
    db_secret           = "${var.soa_domain_name}-db-credentials"
    jdbc_connection_url = var.jdbc_connection_url != null ? var.jdbc_connection_url : module.database.jdbc_connection_url
    nfs_server_ip       = module.fss.server_ip
    path                = module.fss.path
  })
}
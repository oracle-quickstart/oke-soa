## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Configure the cluster with kube-config

resource "null_resource" "cluster_kube_config" {

  depends_on = [module.node_pools, module.cluster]

  provisioner "local-exec" {
    command = templatefile("./templates/cluster-kube-config.tpl",
      {
        cluster_id = module.cluster.cluster.id
        region     = var.region
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete all --all"
    on_failure = continue
  }
}

# Create the cluster-admin user to use with the kubernetes dashboard

resource "null_resource" "oke_admin_service_account" {
  count = var.oke_cluster["cluster_options_add_ons_is_kubernetes_dashboard_enabled"] ? 1 : 0

  depends_on = [null_resource.cluster_kube_config]

  provisioner "local-exec" {
    command = "kubectl create -f ./templates/oke-admin.ServiceAccount.yaml"
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete ServiceAccount oke-admin -n kube-system"
    on_failure = continue
  }
}

# # Create the namespace for the OCI Service Broker and Service Catalog

# resource "null_resource" "create_namespace" {

#   depends_on = [null_resource.cluster_kube_config]

#   provisioner "local-exec" {
#     command = "kubectl create namespace soans"
#   }
#   provisioner "local-exec" {
#     when       = destroy
#     command    = "kubectl delete namespace soans"
#     on_failure = continue
#   }
# }

# # Create the user secret to use to pull docker images from Oracle Container Registry

# resource "null_resource" "docker_registry" {

#   depends_on = [null_resource.cluster_kube_config]

#   provisioner "local-exec" {
#     command = templatefile("./templates/docker-registry-secret.tpl",
#       {
#         region        = var.region
#         ocir_username = 
#         ocir_token    = 
#     })
#   }
#   provisioner "local-exec" {
#     when       = destroy
#     command    = "kubectl delete secret ocir-secret -n default"
#     on_failure = continue
#   }

# }


# # Deploy the Kubernetes Operator helm chart

# resource "null_resource" "deploy_wls_operator" {

#   depends_on = [null_resource.osb_credentials, null_resource.deploy_etcd]

#   provisioner "local-exec" {
#     command = templatefile("./templates/deploy-soa.tpl", {
#       useEmbedded = "true"
#     })
#   }
#   provisioner "local-exec" {
#     when       = destroy
#     command    = "helm delete soa --namespace soans"
#     on_failure = continue
#   }
# }

# # Deploy the Traefik helm chart

# resource "null_resource" "deploy_traefik" {

#   depends_on = [null_resource.osb_credentials, null_resource.deploy_etcd]

#   provisioner "local-exec" {
#     command = templatefile("./templates/deploy-soa.tpl", {
#       useEmbedded = "true"
#     })
#   }
#   provisioner "local-exec" {
#     when       = destroy
#     command    = "helm delete soa --namespace soans"
#     on_failure = continue
#   }
# }

# # Deploy the SOA Suite helm chart

# resource "null_resource" "deploy_soa" {

#   depends_on = [null_resource.osb_credentials, null_resource.deploy_etcd]

#   provisioner "local-exec" {
#     command = templatefile("./templates/deploy-soa.tpl", {
#       useEmbedded = "true"
#     })
#   }
#   provisioner "local-exec" {
#     when       = destroy
#     command    = "helm delete soa --namespace soans"
#     on_failure = continue
#   }
# }

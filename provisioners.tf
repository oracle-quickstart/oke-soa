## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Configure the cluster with kube-config

resource "null_resource" "cluster_kube_config" {

  count = var.provision_cluster ? 1 : 0

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
    command    = "kubectl delete all --all --force"
    on_failure = continue
  }
}

# Create the cluster-admin user to use with the kubernetes dashboard

resource "null_resource" "oke_admin_service_account" {
  count = var.provision_cluster && var.oke_cluster["cluster_options_add_ons_is_kubernetes_dashboard_enabled"] ? 1 : 0

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

# Create the namespace for the WebLogic Operator

resource "null_resource" "create_wls_operator_namespace" {
  count = var.provision_weblogic_operator ? 1 : 0

  depends_on = [null_resource.cluster_kube_config]

  triggers = {
    weblogic_operator_namespace = var.weblogic_operator_namespace
  }

  provisioner "local-exec" {
    command = "kubectl create namespace ${var.weblogic_operator_namespace}"
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete all -n ${self.triggers.weblogic_operator_namespace} --force && kubectl delete namespace ${self.triggers.weblogic_operator_namespace}"
    on_failure = continue
  }
}

# Create the namespace for the SOA deployment
resource "null_resource" "create_soa_namespace" {
  depends_on = [null_resource.cluster_kube_config]

  triggers = {
    soa_kubernetes_namespace = var.soa_kubernetes_namespace
  }

  provisioner "local-exec" {
    command = "kubectl create namespace ${var.soa_kubernetes_namespace}"
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete all -n ${self.triggers.soa_kubernetes_namespace} --force && kubectl delete namespace ${self.triggers.soa_kubernetes_namespace}"
    on_failure = continue
  }
}

# Create the user secret to use to pull docker images from Oracle Container Registry

resource "null_resource" "docker_registry" {

  depends_on = [null_resource.cluster_kube_config, null_resource.create_soa_namespace]

  triggers = {
    soa_kubernetes_namespace = var.soa_kubernetes_namespace
  }

  provisioner "local-exec" {
    command = templatefile("./templates/docker-registry-secret.tpl",
      {
        email     = var.container_registry_email
        password  = var.container_registry_password
        namespace = var.soa_kubernetes_namespace
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete secret image-secret -n ${self.triggers.soa_kubernetes_namespace}"
    on_failure = continue
  }
}

# Create the namespace for the Traefik deployment
resource "null_resource" "create_traefik_namespace" {

  count = var.provision_traefik ? 1 : 0

  depends_on = [null_resource.cluster_kube_config]

  triggers = {
    ingress_namespace = var.ingress_controller_namespace
  }

  provisioner "local-exec" {
    command = "if [[ ! $(kubectl get ns ${var.ingress_controller_namespace}) ]]; then kubectl create namespace ${var.ingress_controller_namespace}; fi"
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete namespace ${self.triggers.ingress_namespace}"
    on_failure = continue
  }
}

# Deploy the Kubernetes Operator helm chart

resource "null_resource" "deploy_wls_operator" {

  count = var.provision_weblogic_operator ? 1 : 0

  depends_on = [null_resource.create_wls_operator_namespace, null_resource.create_soa_namespace]

  triggers = {
    weblogic_operator_namespace = var.weblogic_operator_namespace
    soa_namespace               = var.soa_kubernetes_namespace
  }

  provisioner "local-exec" {
    command = templatefile("./templates/deploy-weblogic-operator.tpl", {
      weblogic_operator_namespace = var.weblogic_operator_namespace
      soa_namespace               = var.soa_kubernetes_namespace
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "helm delete weblogic-operator --namespace ${self.triggers.weblogic_operator_namespace} && kubectl delete crds domains.weblogic.oracle"
    on_failure = continue
  }
}

# Deploy the Traefik helm chart

resource "null_resource" "deploy_traefik" {
  count = var.provision_traefik ? 1 : 0

  depends_on = [null_resource.create_traefik_namespace, null_resource.create_soa_namespace]

  triggers = {
    ingress_namespace = var.ingress_controller_namespace
    soa_namespace     = var.soa_kubernetes_namespace
  }

  provisioner "local-exec" {
    command = templatefile("./templates/deploy-traefik.tpl", {
      ingress_namespace = var.ingress_controller_namespace
      soa_namespace     = var.soa_kubernetes_namespace
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "helm delete traefik --namespace ${self.triggers.ingress_namespace}"
    on_failure = continue
  }
}

# Create secrets
resource "null_resource" "create_soa_domain_secret" {
  count = var.provision_secrets ? 1 : 0

  depends_on = [null_resource.create_soa_namespace]

  triggers = {
    name      = "${var.soa_domain_name}-domain-credentials"
    namespace = var.soa_kubernetes_namespace
    username  = var.soa_domain_admin_username
    password  = var.soa_domain_admin_password
  }

  provisioner "local-exec" {
    command = templatefile("./templates/create_secret.tpl", {
      name      = "${var.soa_domain_name}-domain-credentials"
      namespace = var.soa_kubernetes_namespace
      username  = var.soa_domain_admin_username
      password  = var.soa_domain_admin_password
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete secret ${self.triggers.name} --namespace ${self.triggers.namespace}"
    on_failure = continue
  }
}

resource "null_resource" "create_rcu_secret" {
  count = var.provision_secrets ? 1 : 0

  depends_on = [null_resource.create_soa_namespace]

  triggers = {
    name      = "${var.soa_domain_name}-rcu-credentials"
    namespace = var.soa_kubernetes_namespace
    username  = var.rcu_username
    password  = var.rcu_password
  }

  provisioner "local-exec" {
    command = templatefile("./templates/create_secret.tpl", {
      name      = "${var.soa_domain_name}-rcu-credentials"
      namespace = var.soa_kubernetes_namespace
      username  = var.rcu_username
      password  = var.rcu_password
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete secret ${self.triggers.name} --namespace ${self.triggers.namespace}"
    on_failure = continue
  }
}

resource "null_resource" "create_db_secret" {
  count = var.provision_secrets ? 1 : 0

  depends_on = [null_resource.create_soa_namespace]

  triggers = {
    name      = "${var.soa_domain_name}-db-credentials"
    namespace = var.soa_kubernetes_namespace
    username  = "SYS"
    password  = var.db_sys_password
  }

  provisioner "local-exec" {
    command = templatefile("./templates/create_secret.tpl", {
      name      = "${var.soa_domain_name}-db-credentials"
      namespace = var.soa_kubernetes_namespace
      username  = "SYS"
      password  = var.db_sys_password
    })
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete secret ${self.triggers.name} --namespace ${self.triggers.namespace}"
    on_failure = continue
  }
}


# Deploy the SOA Suite helm chart

resource "null_resource" "deploy_soa" {
  count = var.provision_soa ? 1 : 0

  depends_on = [
    null_resource.deploy_wls_operator,
    null_resource.deploy_traefik,
    module.database,
    null_resource.docker_registry,
    null_resource.create_db_secret,
    null_resource.create_rcu_secret,
    null_resource.create_soa_domain_secret,
    local_file.helm_values
  ]

  triggers = {
    soa_domain_name   = var.soa_domain_name
    soa_domain_type   = var.soa_domain_type
    soa_namespace     = var.soa_kubernetes_namespace
    soa_domain_secret = "${var.soa_domain_name}-domain-credentials"
    rcu_prefix        = var.rcu_prefix
    rcu_secret        = "${var.soa_domain_name}-rcu-credentials"
    db_secret         = "${var.soa_domain_name}-db-credentials"
    # soa_admin_username  = var.soa_domain_admin_username
    # soa_admin_password  = var.soa_domain_admin_password
    # rcu_username        = var.rcu_username
    # rcu_password        = var.rcu_password
    jdbc_connection_url = var.jdbc_connection_url != null ? var.jdbc_connection_url : module.database.jdbc_connection_url
    # db_sys_password     = var.db_sys_password
    nfs_server_ip = module.fss.server_ip
    path          = module.fss.path
  }

  provisioner "local-exec" {
    command = templatefile("./templates/deploy-soa.tpl", {
      soa_domain_name   = var.soa_domain_name
      soa_domain_type   = var.soa_domain_type
      soa_namespace     = var.soa_kubernetes_namespace
      soa_domain_secret = "${var.soa_domain_name}-domain-credentials"
      rcu_prefix        = var.rcu_prefix
      rcu_secret        = "${var.soa_domain_name}-rcu-credentials"
      db_secret         = "${var.soa_domain_name}-db-credentials"
      # soa_admin_username  = var.soa_domain_admin_username
      # soa_admin_password  = var.soa_domain_admin_password
      # rcu_username        = var.rcu_username
      # rcu_password        = var.rcu_password
      jdbc_connection_url = var.jdbc_connection_url != null ? var.jdbc_connection_url : module.database.jdbc_connection_url
      # db_sys_password     = var.db_sys_password
      nfs_server_ip = module.fss.server_ip
      path          = module.fss.path
    })
  }
  provisioner "local-exec" {
    when = destroy
    command = templatefile("./templates/undeploy-soa.tpl", {
      soa_domain_name = self.triggers.soa_domain_name
      soa_namespace   = self.triggers.soa_namespace
    })
    on_failure = continue
  }
}

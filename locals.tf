#locals {
#    # Networking
#    vcn_name = "${var.deployment_name}-vcn"
#    lb_subnet_name = "${var.deployment_name}-lb-subnet"
#    nodes_subnet_name = "${var.deployment_name}-nodes-subnet"
#    
#    # OKE
#    cluster_name = "${var.deployment_name}-oke"
#    node_pool_name = "${var.deployment_name}-node_pool"
#}

# random integer id suffix for the users
resource "random_integer" "random" {
  min = 1
  max = 100
}

locals {
  cluster_name                  = "${var.deployment_name}-oke"
  cluster_idx                   = substr(md5(module.cluster.cluster.id), 0, 4)
  idx                           = random_integer.random.result
}
# Oracle SOA Suite on Kubernetes

## Disclaimer

This deployment of Oracle SOA Suite makes use of the Oracle SOA Suite Helm Chart based on the [fmw-kubernetes](https://github.com/oracle/fmw-kubernetes) release.

The Helm chart is provided as an example and is not currently officially supported by Oracle. Refer to the [fmw-kubernetes](https://github.com/oracle/fmw-kubernetes) release for the officially supported deployment.

## Caveats

Although this release follows the same flow as the [fmw-kubernetes](https://github.com/oracle/fmw-kubernetes) release, only the Traefik ingress controller is currently supported.

## 1. Prerequisites

### 1.1 Software Requirements

This terraform deployment requires the prior installation of the following:

- **terraform >= 0.14**

    [tfswitch](https://tfswitch.warrensbox.com/Install/) can be used for flexibility of working with multiple versions of terraform, but it is only available on Linux and Mac OS X, for Windows or if you prefer to install the base software, see [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli) for basic installation instructions.

- **kubectl >= 1.18.10 (the Kubernetes cli)**

    See [https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions, although kubectl is usually installed as part of Docker Desktop, so if you use Docker it is likely already installed.

- **helm >= 3.5.4**

    Helm is a kubernetes deployment package manager. The OCI Service Broker is packaged in a Helm chart, and so is the etcd cluster deployment.
    See [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/) to install helm locally.

- **OCI Command Line Interface (CLI)**

    See [https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) for a quick starting guide. Make sure you upload your **public key** in your OCI account and note the fingerprint information.

    The OCI CLI is used to configure the access to the OKE cluster locally only, so this deployment could be modified to only use `kubectl` if this is intended for a remote setup, but configuring the CLI helps in several tasks.

### 1.2 Oracle SOA Suite Docker Image

The chart uses the Oracle SOA Suite Docker image from the Oracle Container Registry. This is a mandatory requirement.

You must accept the terms of use for this image before using the chart, or it will fail to pull the image from registry.

- At [https://container-registry.oracle.com](https://container-registry.oracle.com), search for 'SOA'.
- Click **soasuite**.
- Click to accept the License terms and condition on the right.
- Fill in your information (if you haven't already).
- Accept the License.

### 1.3 Oracle Database Docker Image

You may provision the database supporting the Oracle SOA suite domain schemas separately, and point the chart to it by providing the database url. The database must be accessible from the Kubernetes cluster. This is the recommended way to deploy this chart.

If you intend on deploying the database within the kubernetes cluster (optional; not for production), you must agree to the terms of the Oracle database Docker image:

- Search for Database.
- Click **Enterprise**.
- Click to accept the License terms and condition on the right.
- Fill in your information (if you haven't already).
- Accept the License.

Note that the deployment in cluster is for testing purpose only and not for production.

## 2. Installation

### 2.1 Fork or clone the repository

Create a local copy of this repository. You can make that with the commands:

```bash
git clone https://github.com/oracle-quickstart/oke-soa
cd oke-soa
```

### 2.2 Create a `terraform.tfvars` file

Create a `terraform.tfvars` file from the `terraform.tfvars.template` file and populate the following mandatory information:

```yaml
tenancy_ocid     = "ocid1.tenancy.oc1..."
compartment_ocid = "ocid1.compartment.oc1..."
region           = "us-ashburn-1"

deployment_name = "SOA-k8s"
soa_domain_name = "mysoa"

# Domain Type musrt be one of soa, soaess, soaosb, soaessosb
soa_domain_type = "soaessosb"

## Things to provision

# VCN, OKE cluster, node_pool(s)
# if false, the template assumes the cluster is provisioned and that kubectl has access to the cluster.
provision_cluster = true

# File Storage and mount point export 
provision_filesystem = true
provision_export = true

# Database (DBaaS on OCI)
# If false, a database jdbc_connection URL needs to be provided, and the database needs to be reachable from this VCN
provision_database = true
# WebLogic Operator
provision_weblogic_operator = true
# Ingress controller
provision_traefik = true
provision_soa = false

## File storage details
# If the VCN is not provided by this template, the following variables must be provided
fss_subnet_id = null
# If the cluster and VCN are not provided by this template,
fss_source_cidr = "0.0.0.0/0"


## Credentials
# Container registry login credentials
container_registry_email    = ""
container_registry_password = ""

# SOA Suite domain Admin Console credentials
soa_domain_admin_username = ""
soa_domain_admin_password = ""

# Database credentials
db_sys_password = ""

# RCU Schema credentials
rcu_prefix = "SOA"
rcu_username = "rcu"
rcu_password = ""

# If connecting to an external DB, specify the jdbc_connection_url
# !!! You will need to adjust the security list on your database VCN/subnet to authorize access from the OKE cluster nodes,
# which may require VCN peering (not provided here)
jdbc_connection_url = null

# Database information
database_name        = "SOA"
database_unique_name = "SOA"

# Kubernetes namespaces
soa_kubernetes_namespace     = "soans"
weblogic_operator_namespace  = "opns"
ingress_controller_namespace = "traefik"

# VCN config
vcn_cidr = "10.0.0.0/16"

# SSH key to access database and Kubernetes nodes
ssh_authorized_key = ""

# Optional parameter, requires a vault and key to be created in the account.
secrets_encryption_key_ocid = null
```

If you wish to encrypt Kubernetes secrets at rest, you can provision a vault and key and reference this key OCID as `secrets_encryption_key_ocid` to use in the kubernetes cluster.

### 2.3 Deployment Options

By default, the template will deploy the following infrastrucutre resources:

- A Virtual Cloud Network (VCN).
- Subnets for the Kubernetes Load Balancers (public subnet) and nodes (private subnet).
- A Kubernetes cluster on the Oracle Kubernetes Engine service.
- A database on the Oracle Database Service.
- A file storage Network File Server (NFS) and mount point export path.
- Security lists to allow proper communication.

On the Kubernetes cluster provisioned, the template also create or deploy:

- Namespaces for the different components.
- The secrets containing the credentials required.
- The required WebLogic Operator Helm chart the SOA Suite chart requires.
- The required ingress controller (using Traefik).

By default the template will deploy the Oracle SOA Suite Helm chart, but it may not be what you need:

- If you are testing this chart and you plan on deploying only one cluster and one SOA Suite installation, the variable `provision_soa` can be kept `true` in the `terraform.tfvars` config file.

- If you plan on deploying multiple SOA Suite domains in the cluster, set it to `false` and follow the Helm chart deployment instructions below. While it is convenient to deploy the whole installation in one command, because Terraform keeps track of the state of the deployment, it is not possible to create an additional SOA domain by simply changing the variable inputs without destroying the original domain. Doing so would require cloning the whole repo again and starting over. Therefore if you plan on deploying multiple SOA domains on the cluster, use the Helm commands directly to deploy your domains.

### 2.4 Deploy the Infrastructure

Use the following commands:

```bash
    terraform init
    terraform plan
    terraform apply
```

and answer **Yes** at the prompt to deploy the stack.

### 2.5 Deploy the Oracle SOA Helm chart

If you have opted for the default deployment, which deploys the SOA Suite chart by default, you are done. Wait for the pods to be in the READY state.

Otherwise to deploy a SOA domain (or an additional SOA domain), use the following command:

```bash
helm repo add oracle https://streamnsight.github.io/helmcharts --force-update

helm install ${soa_domain_name} oracle/soa-suite \
    -f fromtf.auto.yaml \
    --namespace ${soa_namespace} \
    --version 0.1.0 \
    --wait  \
    --timeout 600s
```

This makes use of the `fromtf.auto.yaml` values generated by the terraform template.


## Access the Deployment

1. Get the public IP of the load balancer created by the ingress controller

    ```bash
    <copy>
    kubectl get services -n traefik
    </copy>
    ```

    This should output something like:

    ```bash
    NAME      TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                          AGE
    traefik   LoadBalancer   10.2.170.178   123.456.789.123  9000:31242/TCP,30305:30305/TCP,30443:30443/TCP   3m
    ```

    If it is still pending, wait a few more minutes before checking again.

    Get the EXTERNAL-IP value for the load balancer

2. Make sure the SOA domain servers are running:

    If you have not changed the name of the soa namespace, you can check running pods with:

    ```bash
    <copy>
    kubectl get pods -n soans
    </copy>
    ```

    You should see:

    ```bash
    NAME                READY   STATUS    RESTARTS   AGE    IP          NODE          NOMINATED NODE   READINESS GATES
    mysoa-adminserver   1/1     Running   0          179m   10.1.1.9    10.0.10.211   <none>           <none>
    mysoa-osb-server1   1/1     Running   0          172m   10.1.1.10   10.0.10.211   <none>           <none>
    mysoa-osb-server2   1/1     Running   0          172m   10.1.1.12   10.0.10.211   <none>           <none>
    mysoa-soa-server1   1/1     Running   0          172m   10.1.1.11   10.0.10.211   <none>           <none>
    mysoa-soa-server2   1/1     Running   0          172m   10.1.0.6    10.0.10.16    <none>           <none>
    ```

    Make sure the STATUS is `RUNNING` and that READY is `1/1` for pods above before checking the URL

3. With the public IP gathered earlier, browse to http://*PUBLIC_IP*:30305/console to get to the WebLogic console.

4. You can log into the console with the `soa_domain_username` and `soa_domain_password` you specified in the `terraform,.tfvars` file.

5. Check the `ess` endpoint by browsing to http://*PUBLIC_IP*:30305/ess .

## Accessing the Kubernetes UI

To access the Kubernetes Cluster UI, you can use the following snipet:

```bash
# Get an access token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}')

# run a kube proxy
kubectl proxy &

# open your browser to
open 'http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login'
```

or use the provided helper script `access_k8s_dashboard.sh`

## Undeploying a SOA Suite domain

To undeploy a SOA domain created with the Terraform template (`provision_soa=true`), use the following command:

```bash
terraform destroy --target=null_resource.deploy_soa
```

To undeploy a SOA domain created manually with Helm, you first need to shut down the domain by updating the helm chart with

```bash
helm update ${soa_domain_name} oracle/soa-suite \
  -n ${soa_namespace} \
  --reuse-values \
  --set domain.enabled=false \
  --wait
```

Once the domain is terminated, use:

```bash
helm delete ${soa_domain_name} -n ${soa_namespace}
```

## Destroy the Deployment

When you no longer need the deployment, you can run this command to destroy everything (VCN, cluster, database, file storage and all the kubernetes objects):

```bash
terraform destroy
```

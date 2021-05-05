# oke-with-service-broker

This reference architecture creates an Oracle Kubernetes Engine cluster with a node pool with 3 nodes, and deploys the OCI Service Broker following recommended best practices.

[OCI Service Broker](https://github.com/oracle/oci-service-broker) is an open-source project allowing the definition and the management of the life-cycle of Oracle Cloud managed services including Object Storage standard and archive buckets, Autonomous Database (ATP and ADW) and the Streaming service.

OCI Service Broker (OSB) uses etcd as a data store, which is deployed as part of this deployment.

## Terraform Provider for Oracle Cloud Infrastructure
The OCI Terraform Provider is now available for automatic download through the Terraform Provider Registry. 
For more information on how to get started view the [documentation](https://www.terraform.io/docs/providers/oci/index.html) 
and [setup guide](https://www.terraform.io/docs/providers/oci/guides/version-3-upgrade.html).

* [Documentation](https://www.terraform.io/docs/providers/oci/index.html)
* [OCI forums](https://cloudcustomerconnect.oracle.com/resources/9c8fa8f96f/summary)
* [Github issues](https://github.com/terraform-providers/terraform-provider-oci/issues)
* [Troubleshooting](https://www.terraform.io/docs/providers/oci/guides/guides/troubleshooting.html)

## Installation


### Dependencies

This terraform deployment requires the prior installation of the following:

- **terraform >= 0.13**

    [tfswitch](https://tfswitch.warrensbox.com/Install/) can be used for flexibility of working with multiple versions of terraform, but it is only available on Linux and Mac OS X, for Windows or if you prefer to install the base software, see [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli) for basic installation instructions. 

- **kubectl >= 0.18 (the Kubernetes cli)**

    See [https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions, although kubectl is usually installed as part of Docker Desktop, so if you use Docker it is likely already installed

- **helm 3.x**

    Helm is a kubernetes deployment package manager. The OCI Service Broker is packaged in a Helm chart, and so is the etcd cluster deployment.
    See [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/) to install helm locally.

- **OCI CLI**

    See [https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) for a quick starting guide. Make sure you upload your **public key** in your OCI account and note the fingerprint information.
    
    The OCI CLI is used to configure the access to the OKE cluster locally only, so this deployment could be modified to only use `kubectl` if this is intended for a remote setup, but configuring the CLI helps in several tasks.

### 1) Clone the repository

Create a local copy of this repository. You can make that with the commands:

```bash
git clone https://github.com/oracle-quickstart/oke-with-service-broker
cd oke-with-service-broker
```

### 2) Create and source a `TF_VARS.sh` file

In order to be able to work in multiple environments, it is convenient to place required terraform variables in environment variables

We'll use a file called `TF_VARS.sh` that can be sourced

The file must contain the following variables:

```
export TF_VAR_user_ocid=ocid1.user.oc1..
export TF_VAR_fingerprint=dc:6e:...
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..
export TF_VAR_region=us-ashburn-1
```

Some of this information is generated when installing the OCI CLI, but you may also use a different ssh key.

Source the file in your shell with:

```bash
source ./TF_VARS.sh
# or more simply, to achieve the same:
. ./TF_VARS.sh
```

### 3) Create a `terraform.tfvars` file

Create a `terraform.tfvars` file from the `terraform.tfvars.template` file and populate the following mandatory information:

```
tenancy_ocid = ""
compartment_ocid = ""
region           = ""
ssh_authorized_key = ""

secrets_encryption_key_ocid = null
```

You can also re-use groups that were previously created, by providing the group_ocid.

The templates gives the option to provide:

```
# a group for users to pull images from OCI Registry
ocir_puller_group_ocid = null
# a group for users to manage the lifecycle of Autonmous databases (ATP, ADW), Streams of the streaming service, and object storage buckets.
osb_group_ocid = null
```

If you wish to encrypt Kubernetes secrets at rest, you can provision a vault and key and reference this key OCID as `secrets_encryption_key_ocid` to use in the kubernetes cluster.

### 4) Deploy the infrastructure

Use the following commands:

```bash
    terraform init
    terraform plan
    terraform apply
```

and answer **Yes** at the prompt to deploy the stack.

## What it does

The deployment creates:

- An Oracle Kubernetes Engine (OKE) cluster, and generates credentials to access it, which are automatically merged with your local `kubeconfig` for use without other setup

- A `ocir_puller` group and a user with policy allowing the user to pull container images in the compartment. The credentials for this user are stored in a secret of type `docker-registry` named `ocir-secret` in the `default` namespace, which can be used for deployments needing to pull images from the OCI Registry in your tenancy.

  *Note that if you need to pull images for a deployment in a different namespace, you will need to copy the secret to the other namespace.*

- In addition, it creates a `osb_user` group and user with policy allowing management of Autonmous DBs, Streaming and Object Storage resources, whose OCI credentials are stored in a secret called `osbcredentials`, as required by the OCI Service Broker to interact with the OCI services.

It also creates, under the `keys` folder:

- A root Certificate Authority and self-signed CA Certificate, along with client and peer certificates and keys for TLS encryption and authentication of the etcd cluster used as backend store for the OCI Service Broker.

In a namespace called `oci-service-broker`, it deploys:

- The `etcd` cluster as a StatefulSet of 3 etcd nodes (requiring at least 3 nodes in the node pool), using encrypted transport as well as client/server authentication with TLS.

- The Service Catalog extension of Kubernetes to support the broker

- The OCI Service Broker itself

and registers the OCI Service Broker with the Service Catalog.

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

## What's next?

Once the OCI Service Broker is deployed, you can now provision Streams for Oracle Streaming Service, Autonomous Transaction Processing Databases, or Data Warehouses, and create/delete Object Storage buckets following the <a href="https://github.com/oracle/oci-service-broker/tree/master/charts/oci-service-broker/samples" target="_blank">examples in the OCI Service Broker repository</a>

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

```bash
terraform destroy
```

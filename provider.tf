## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    oci = {
      version = ">= 4.24.0"
    }
  }
}

provider "oci" {
  region               = var.region
  disable_auto_retries = "true"
}

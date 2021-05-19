## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_db_system" "db_system" {
  count = var.provision_database ? 1 : 0

  #Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains.0.name
  compartment_id      = var.compartment_ocid
  db_home {
    #Required
    database {
      #Required
      admin_password = var.admin_password

      #Optional
      db_name     = var.database_name
      db_workload = "OLTP"
      # defined_tags = var.db_system_db_home_database_defined_tags
      # freeform_tags = var.db_system_db_home_database_freeform_tags
      # ncharacter_set = var.db_system_db_home_database_ncharacter_set
      pdb_name = var.pdb_name
      # tde_wallet_password = var.db_system_db_home_database_tde_wallet_password
      # time_stamp_for_point_in_time_recovery = var.db_system_db_home_database_time_stamp_for_point_in_time_recovery
    }

    #Optional
    # database_software_image_id = oci_database_database_software_image.test_database_software_image.id
    db_version = "19.0.0.0"
    # defined_tags = var.db_system_db_home_defined_tags
    display_name = var.database_name
    # freeform_tags = var.db_system_db_home_freeform_tags
  }
  hostname        = "db"
  shape           = var.db_system_shape
  ssh_public_keys = var.ssh_public_keys
  subnet_id       = var.subnet_id

  #Optional
  # backup_network_nsg_ids = var.db_system_backup_network_nsg_ids
  # backup_subnet_id = oci_core_subnet.test_subnet.id
  # cluster_name = var.db_system_cluster_name
  cpu_core_count = var.db_system_cpu_core_count
  # data_storage_percentage = var.db_system_data_storage_percentage
  data_storage_size_in_gb = var.db_system_data_storage_size_in_gb
  database_edition        = var.db_system_database_edition
  db_system_options {

    #Optional
    storage_management = var.db_system_db_system_options_storage_management
  }
  # defined_tags = var.db_system_defined_tags
  # disk_redundancy = var.db_system_disk_redundancy
  # display_name = var.db_system_display_name
  # domain = var.db_system_domain
  # fault_domains = var.db_system_fault_domains
  # freeform_tags = {"Department"= "Finance"}
  # kms_key_id = oci_kms_key.test_key.id
  # kms_key_version_id = oci_kms_key_version.test_key_version.id
  license_model = var.db_system_license_model
  # maintenance_window_details {

  #     #Optional
  #     days_of_week {

  #         #Optional
  #         name = var.db_system_maintenance_window_details_days_of_week_name
  #     }
  #     hours_of_day = var.db_system_maintenance_window_details_hours_of_day
  #     lead_time_in_weeks = var.db_system_maintenance_window_details_lead_time_in_weeks
  #     months {

  #         #Optional
  #         name = var.db_system_maintenance_window_details_months_name
  #     }
  #     preference = var.db_system_maintenance_window_details_preference
  #     weeks_of_month = var.db_system_maintenance_window_details_weeks_of_month
  # }
  node_count = 1
  # nsg_ids = var.db_system_nsg_ids
}
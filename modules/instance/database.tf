/* database */

# data "oci_database_autonomous_databases" "test_autonomous_databases" {
#   #Required
#   compartment_id = var.compartment_ocid

#   #Optional
#   db_workload  = "OLTP"
#   is_free_tier = "true"
# }

# resource "oci_database_autonomous_database" "test_autonomous_database" {
#   #Required
#   admin_password          = "Testalwaysfree1"
#   compartment_id          = var.compartment_ocid
#   cpu_core_count          = "1"
#   data_storage_size_in_gb = "20"
#   db_name                 = "testadb"

#   #Optional
#   db_workload  = "OLTP"
#   display_name = "test_autonomous_database"

#   freeform_tags = {
#     "Department" = "Finance"
#   }

#   is_auto_scaling_enabled = "false"
#   license_model           = "LICENSE_INCLUDED"
#   is_free_tier            = "true"
# }

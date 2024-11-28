
# vcn ( subnet, gateway, routeTable, securityList )
resource "oci_core_virtual_network" "app_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = "app_VCN"
  dns_label      = "appvcn"
}

resource "oci_core_subnet" "app_subnet" {
  cidr_block        = var.subnet_cidr_block
  display_name      = "app_subnet"
  dns_label         = "appsubnet"
  security_list_ids = [oci_core_security_list.app_security_list.id]
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_virtual_network.app_vcn.id
  route_table_id    = oci_core_route_table.app_route_table.id
  dhcp_options_id   = oci_core_virtual_network.app_vcn.default_dhcp_options_id
}

# internet_gateway
resource "oci_core_internet_gateway" "app_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.app_vcn.id
  display_name   = "app_inet_gateway"
}

# route table
resource "oci_core_route_table" "app_route_table" {
  vcn_id = oci_core_virtual_network.app_vcn.id
  #Required  
  compartment_id = var.compartment_id

  # Optional
  display_name = "app_route_table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.app_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# security list
resource "oci_core_security_list" "app_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.app_vcn.id
  display_name   = "appSecurityList"

  dynamic "egress_security_rules" {
    for_each = var.egress_security_rules
    iterator = security_rule
    content {
      protocol         = security_rule.value["protocol"]
      destination      = security_rule.value["destination"]
      destination_type = security_rule.value["destination_type"]
      description      = security_rule.value["description"]
    }
  }
  dynamic "ingress_security_rules" {
    for_each = {
      for k, v in var.ingress_security_rules : k => v if v["protocol"] == "6"
    }
    iterator = security_rule
    content {
      protocol    = security_rule.value["protocol"]
      source      = security_rule.value["source"]
      source_type = security_rule.value["source_type"]
      description = security_rule.value["description"]
      tcp_options {
        max = security_rule.value["port"]
        min = security_rule.value["port"]
      }
    }
  }
  ingress_security_rules {
    protocol    = "all"
    source      = var.my_public_ip
    source_type = "CIDR_BLOCK"
    description = "Allow my public IP for all protocols"
  }
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow subnet for all protocols"
  }
  ingress_security_rules {
    protocol    = 1
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow subnet for ICMP"
    icmp_options {
      type = 3
    }
  }
}

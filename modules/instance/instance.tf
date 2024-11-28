# See https://docs.oracle.com/iaas/images/
data "oci_core_images" "instance" {
  compartment_id           = var.compartment_id
  operating_system         = var.imageOS
  operating_system_version = var.imageOSVersion
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  docker_source = "./resource/docker"
  docker_init   = "./resource/scripts/init-docker.tpl"
}

resource "oci_core_instance" "app_node" {
  count = var.instance_count

  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute RDMA GPU Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Auto-Configuration"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Authentication"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }

  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  display_name        = "app_node${count.index}"

  preserve_boot_volume = false
  shape                = var.instance_shape
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.instance.images[0], "id")
  }

  create_vnic_details {
    subnet_id        = var.app_subnet_id # module.oci-network
    display_name     = "primaryvnic"
    assign_ipv6ip    = false
    assign_public_ip = true
    hostname_label   = "app_node${count.index}"
  }

  metadata = {
    ssh_authorized_keys = (var.ssh_public_key != "") ? file(var.ssh_public_key) : tls_private_key.compute_ssh_key.public_key_openssh
    user_data           = "${base64encode(templatefile(local.docker_init, { docker_secret_key = var.docker_secret_key }))}"
  }

  provisioner "file" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
      timeout     = "3m"
      agent       = false
    }
    source      = local.docker_source
    destination = "/home/ubuntu/docker"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
      timeout     = "3m"
      agent       = false
    }
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 5; done",
      "sudo docker ps",
      "sudo docker-compose --version",
      "sudo docker-compose --env-file /home/ubuntu/docker/.env -f /home/ubuntu/docker/docker-compose.yml up -d", # Install
      "sudo iptables -A INPUT -i enp0s6 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT",
      "sudo iptables -A INPUT -i enp0s6 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT",
    ]
  }
}

# vnic
data "oci_core_vnic_attachments" "app_vnics" {
  count = var.instance_count

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.app_node[count.index].id
}

data "oci_core_vnic" "app_vnic" {
  count   = var.instance_count
  vnic_id = data.oci_core_vnic_attachments.app_vnics[count.index].vnic_attachments[0]["vnic_id"]
}

#файл шаблон для создания пустых инстансев в гугл клауде
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.59.0"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file("cred_file.json")
  project     = "имя проекта"
  region      = "us-central1"
  zone      = "us-central1-a"
}

resource "google_compute_instance" "terra-shablon" {
  name         = "terra-shablon"
  #machine_type = "e2-micro" // 2vCPU, 1 GB RAM
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM / 6.5GB RAM per CPU, if needed more refer to next line
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  #tags = ["terra", "shablon"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size = "10" // size in GB for Disk
      type = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP and external static IP
      #nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}" // Point to ssh public key for user root
  }

    provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install python3 -y",
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

  // A variable for extracting the external IP address of the instance
  output "ip" {
  value = google_compute_instance.terra-shablon.network_interface.0.access_config.0.nat_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.terra-fin]

  create_duration = "30s" // Change to 90s
}

resource "null_resource" "ansible_hosts_provisioner" {
  depends_on = [time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOT
      export gcp_public_ip=$(terraform output ip);
      echo $gcp_public_ip;
      sed -i -e "s/gcp_instance_ip/$gcp_public_ip/g" ./inventory/hosts;
      sed -i -e 's/"//g' ./inventory/hosts;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [null_resource.ansible_hosts_provisioner]

  create_duration = "5s"
}

resource "null_resource" "ansible_playbook_provisioner" {
  depends_on = [time_sleep.wait_5_seconds]
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -u root --private-key './key1' -i inventory/hosts site.yml;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}


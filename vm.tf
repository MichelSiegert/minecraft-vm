resource "google_compute_address" "minecraft_ip" {
  name   = "minecraft-server-ip"
  region = var.region
  project = var.project_id
}

resource "google_compute_instance" "minecraft_server" {
depends_on = [ 
  google_project_iam_member.minecraft_vm_storage,
  google_project_iam_member.minecraft_vm_compute,
  google_service_account.minecraft_vm
 ]

  name         = "minecraft-server"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  project = var.project_id

  metadata_startup_script = data.template_file.startup_script.rendered
  
  metadata = {
    enable-oslogin = "false"
    }

  tags = ["minecraft"]
  network_interface {
    network = "default"
    access_config {
          nat_ip = google_compute_address.minecraft_ip.address
    }
  }

    service_account {
    email  = google_service_account.minecraft_vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}

output "minecraft_server_internal_ip" {
  description = "The internal IP of the Minecraft server"
  value       = google_compute_instance.minecraft_server.network_interface[0].network_ip
}
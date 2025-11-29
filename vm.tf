resource "google_compute_instance" "minecraft_server" {
  depends_on = [
    google_project_iam_member.minecraft_vm_storage,
    google_project_iam_member.minecraft_vm_compute,
    google_service_account.minecraft_vm,
    google_storage_bucket_object.world_zip
  ]

  name         = "minecraft-server"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  project = var.project_id

  metadata_startup_script = local.startup_script

  metadata = {
    enable-oslogin = "false"
  }

  tags = ["minecraft"]
  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.minecraft_vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}

output "minecraft_server_external_ip" {
  description = "ip of the server"
  value       = google_compute_instance.minecraft_server.network_interface[0].access_config[0].nat_ip
}

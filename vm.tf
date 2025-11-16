resource "google_compute_address" "minecraft_ip" {
  name   = "minecraft-server-ip"
  region = var.region
  project = var.project_id
}


resource "google_compute_instance" "minecraft_server" {
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
    shutdown-script = data.template_file.shutdown_script.rendered
    }

  tags = ["minecraft"]
  network_interface {
    network = "default"
    access_config {
          nat_ip = google_compute_address.minecraft_ip.address
    }
  }
}

resource "google_compute_firewall" "mc_fw" {
  name    = "minecraft-fw"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["25565", "25575"]
  }
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["minecraft"]
}

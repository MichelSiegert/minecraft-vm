resource "google_storage_bucket" "mc_backup" {
  name     = "minecraft-backups-myloooooof"
  location = var.region
  force_destroy = true 
}

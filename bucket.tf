resource "google_storage_bucket" "mc_backup" {
  name     = "minecraft-backups-myloooooof"
  location = var.region
  force_destroy = true 
}

resource "google_storage_bucket_object" "world_zip" {
  depends_on = [ google_storage_bucket.mc_backup ]
  count  = var.local_world_zip != "" ? 1 : 0
  name   = "world.zip"
  bucket = google_storage_bucket.mc_backup.name
  source = var.local_world_zip
}


resource "google_service_account" "minecraft_vm" {
  account_id   = "minecraft-vm-sa"
  display_name = "Minecraft VM Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "minecraft_vm_storage" {
  depends_on = [
    google_project_service.cloudresourcemanager,
    google_service_account.minecraft_vm
  ]
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.minecraft_vm.email}"
}

resource "google_project_iam_member" "minecraft_vm_compute" {
  depends_on = [
    google_project_service.cloudresourcemanager,
    google_service_account.minecraft_vm
  ]
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_vm.email}"
}

resource "google_service_account" "minecraft_function" {
  account_id   = "minecraft-fn-sa"
  display_name = "Minecraft Function Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "fn_compute" {
  depends_on = [
    google_project_service.cloudresourcemanager
  ]
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_function.email}"
}

resource "google_project_iam_member" "fn_sa_user" {
  depends_on = [
    google_project_service.cloudresourcemanager
  ]
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.minecraft_function.email}"
}

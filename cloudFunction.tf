resource "null_resource" "deploy_restart_function" {
  depends_on = [
    google_compute_instance.minecraft_server  
  ]

  provisioner "local-exec" {
    command = <<EOT
      cd ./restarter
      gcloud functions deploy restartMinecraftVM \
        --runtime nodejs20 \
        --trigger-http \
        --allow-unauthenticated \
        --region europe-west3 \
        --memory=512MB
    EOT
  }
}

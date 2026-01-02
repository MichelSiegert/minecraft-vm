locals {
  startup_parts = [
    templatefile("${path.module}/startup/00-install.sh", {}),
    templatefile("${path.module}/startup/10-setup-minecraft.sh", {
      rcon_password = var.rcon_password
    }),
    templatefile("${path.module}/startup/20-idle-shutdown.sh", {
      rcon_password = var.rcon_password
    }),
    templatefile("${path.module}/startup/30-backup.sh", {
      project_id    = var.project_id
      rcon_password = var.rcon_password
    }),
    templatefile("${path.module}/startup/40-restore-world.sh", {
      project_id    = var.project_id
      rcon_password = var.rcon_password
    }),
    templatefile("${path.module}/startup/50-run-server.sh", {
      maximum_memory = var.server_task_memory_maximum_GB
    })
  ]

  startup_script = join("\n\n", local.startup_parts)
}

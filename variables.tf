variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The GCP zone"
  type        = string
}

variable "rcon_password" {
  description = "the RCON passoword"
  type        = string
}

variable "local_sa_keys" {
  description = "Path to local sa keys"
  type        = string
}

variable "local_world_zip" {
  description = "Path to a local Minecraft world zip. Leave empty to skip."
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "type of the machine"
  type        = string
  default     = "e2-medium"
}

variable "server_task_memory_maximum_GB" {
  description = "maximum memory given to the minecraft server in GB."
  type        = number
  default     = 3
}

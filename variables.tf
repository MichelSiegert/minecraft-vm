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

data "template_file" "shutdown_script" {
  template = file("./shutdown.sh")
}

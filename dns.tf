resource "google_dns_managed_zone" "siegert" {
  name        = "siegert-online-zone"
  dns_name    = "siegert.online."
  description = "DNS zone for siegert.online"
}

output "name_servers" {
  value = google_dns_managed_zone.siegert.name_servers
}

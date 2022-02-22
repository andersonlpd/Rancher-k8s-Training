output "subnet_self_link" {
    value = google_compute_subnetwork.subnet.self_link
}

output "output_dns_name" {
    value = google_dns_managed_zone.managed-zone.dns_name
}

output "output_managed_zone" {
    value = google_dns_managed_zone.managed-zone.name
}
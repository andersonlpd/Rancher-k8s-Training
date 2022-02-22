resource "google_compute_network" "vpc-terraform" {
  name                    = var.vpc-name
  auto_create_subnetworks = var.autocreate-subnet
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet-name
  ip_cidr_range = var.ip_subnet
  region        = var.subnet_region
  network       = google_compute_network.vpc-terraform.id
}

//Firewall
resource "google_compute_firewall" "fw-rule-1" {
  name    = var.fw_name_1
  network = google_compute_network.vpc-terraform.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.fw_proto_1
  }

  source_ranges = var.fw_range_1
}

//Managed Zone
resource "google_dns_managed_zone" "managed-zone" {
  name        = var.dns_name
  dns_name    = var.dns_domain_name
  description = "Dorigas DNS zone"
}
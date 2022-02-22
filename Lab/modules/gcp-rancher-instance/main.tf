resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.network-interface
    access_config {
    }
  }

  metadata = {
    ssh-keys = var.pub-ssh-key
  }

  metadata_startup_script = var.deploy_docker
}

resource "google_dns_record_set" "rancher" {
  name = "${var.dns-prefix-name}.${var.domain-name}"
  type = "A"
  ttl  = 300

  managed_zone = var.managedzone-name

  rrdatas = [google_compute_instance.vm.network_interface[0].access_config[0].nat_ip]
}
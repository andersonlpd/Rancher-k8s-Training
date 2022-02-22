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
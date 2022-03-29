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
    ssh-keys = "adorigao:${file(var.key-file)}"
  }

  metadata_startup_script = var.deploy_docker

  //Rancher deploy
  provisioner "file" {
    source      = "scripts/rancher_deploy.sh"
    destination = "/tmp/rancher_deploy.sh"
  }

  provisioner "file" {
    source      = "ssh/adorigao_ssh_key"
    destination = ".ssh/id_rsa"
  }

  connection {
    type        = "ssh"
    user        = "adorigao"
    private_key = file(var.priv-key-file)
    host        = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
  }

}
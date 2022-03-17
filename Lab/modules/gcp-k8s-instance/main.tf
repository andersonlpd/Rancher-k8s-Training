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
    source      = "../scripts/rancher_deploy.sh"
    destination = "/tmp/rancher_deploy.sh"
  }

  provisioner "file" {
    source      = "../ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/rancher_deploy.sh",
      "sudo /tmp/rancher_deploy.sh",
    ]
  }

}
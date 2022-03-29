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

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/rancher_deploy.sh",
      "sudo /tmp/rancher_deploy.sh v2.4.3 1.17.5 rancher.dorigas.tk vm-k8s-1,vm-k8s-2,vm-k8s-3",
    ]
  }

  connection {
    type        = "ssh"
    user        = "adorigao"
    private_key = file(var.priv-key-file)
    host        = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
  }

}

resource "google_dns_record_set" "rancher" {
  name = "${var.dns-prefix-name}.${var.domain-name}"
  type = "A"
  ttl  = 300

  managed_zone = var.managedzone-name

  rrdatas = [google_compute_instance.vm.network_interface[0].access_config[0].nat_ip]
}
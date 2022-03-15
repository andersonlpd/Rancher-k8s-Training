variable "name" {
  type        = string
  description = "nome da instancia"
  default     = "vm-rancher-1"
}

variable "type" {
  type        = string
  description = "Flavor utilizado na instancia"
  default     = "e2-medium"
}

variable "zone" {
  type        = string
  description = "Zona da instancia"
  default     = "us-central1-a"
}

variable "image" {
  type        = string
  description = "Imagem da instancia"
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "network-interface" {
    type        = string
    description = "Subnet da instancia"
    default     = "default"
}

variable "dns-prefix-name" {
    type        = string
    description = "DNS prefix name"
}

variable "domain-name" {
    type        = string
    description = "Record-set name"
}

variable "managedzone-name" {
    type        = string
    description = "Managed Zone Name"
}

variable "pub-ssh-key" {
  type        = string
  description = "Chave SSH pública"
  default     = "adorigao:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRxOQUmBRGE/tzFYrxkq/zpYXGtsygzqDb4410ulkJnITh7faRRcKQaZmIVSLPQznh499+cq/XMeYF3GaBNkMaJOyqxxu9+Tdt0Ng3fa0uA9tKyR3H57m9sXs4t/Jz5viN2iaj4KfDbIP071m+MDjqPwAQSZSKxzZvGRxwN0uQpHpk48aILsCUo0/ti2Pf8ir80txl4UvbRG3Xa3ytT7VuPF6sLFCPY2NtO/75GYyp3Ajlk+guoYuLyab2+AtarTNTEmyewQLt86EdvmDwOhXoOhEYv6jGE88Og4EDB3nCPtiy3j7Xc0gga38L6f/zrqp22mQiKdPSrBl+scnCiVBTQXbcJHPWwasK5gB0I5XXmVjGUrXmwO1I+d9Bawoak8ZTA4pNomGtPCkeh8xAtL3x5LEeSSCbMYwBjtoKyRrRRlfLNCgin3zBlkJK8zPxVqxr/zu/nGqHK7AxGUTXTR76PNfELkmod8iafg31mshfASk0KPtyG1Q/aAFNkTPXP7U= sigterm@DESKTOP-B2RS8AG"
}

variable "deploy_docker" {
  type        = string
  description = "Script de Instalacao do NGINX"
  default     = "curl https://releases.rancher.com/install-docker/19.03.sh | sh; usermod -aG docker adorigao; docker run -d --name rancher --restart=unless-stopped -v /opt/rancher:/var/lib/rancher -p 80:80 -p 443:443 rancher/rancher:v2.4.3"
}
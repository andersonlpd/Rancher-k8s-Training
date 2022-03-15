variable "vpc-name" {
  type        = string
  description = "Nome da VPC"
  default     = "vpc-terraform"
}

variable "autocreate-subnet" {
  type        = bool
  description = "Criacao automatica da subnet S/N"
  default     = false
}

variable "subnet-name" {
  type        = string
  description = "Nome da subnet"
  default     = "vpc-subnet-1"
}

variable "ip_subnet" {
  type        = string
  description = "CIDR da subnet"
  default     = "10.0.0.0/8"
}

variable "subnet_region" {
  type        = string
  description = "Regiao da subnet"
  default     = "us-central1"
}

variable "fw_name_1" {
  type        = string
  description = "Regiao do firewall 1"
  default     = "fw-rule-1"
}

variable "fw_proto_1" {
  type        = list(any)
  description = "Protocolos do firewall 1"
  default     = ["80", "443", "22", "2380", "2379", "10250", "6443"]
}

variable "fw_range_1" {
  type        = list(any)
  description = "Range do firewall 1"
  default     = ["0.0.0.0/0"]
}

variable "dns_name" {
  type        = string
  description = "DNS name"
  default     = "dorigas"
}

variable "dns_domain_name" {
  type        = string
  description = "DNS domain name"
  default     = "dorigas.tk."
}
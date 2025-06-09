variable "vm_count" {
  description = "Nombre de VM à créer"
  type        = number
  default     = 2
}

variable "host_name" {
  description = "Nom de l'utilisateur dans la VM"
  type        = string
  default     = "labvm"
}

variable "ssh_pub_key" {
  description = "Clé SSH publique à injecter dans les VM"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCu..." # Mets ta vraie clé SSH ici
}

variable "user_password_hashed" {
  description = "Mot de passe utilisateur hashé compatible cloud-init (SHA-512)"
  type        = string
  sensitive   = true
  default     = "$6$V9Imdk ...... /eG......m9u1" # Mets ton hash ici # sinon utilser vault, la bonne pratique securisée
}

variable "vault_token" {
  type      = string
  sensitive = true
}

variable "disk_size_gb" {
  type    = number
  default = 20
}

variable "base_path" {
  type    = string
  default = "/home/hichem/vms"
}

variable "source_image" {
  type    = string
  default = "ubuntu-noble-base.qcow2"
}
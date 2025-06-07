variable "vm_count" {
  description = "Nombre de VM à créer"
  type        = number
  default     = 2
}

variable "user_name" {
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
  default     = "$6$V9Imdk ...... /eG......m9u1" # Mets ton hash ici
}

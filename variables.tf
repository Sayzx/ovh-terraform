# ID du souscription Azure
variable "subscription_id" {
  type        = string
  description = "ID de la souscription Azure"
}

# Région Azure
variable "azure_region" {
  type        = string
  description = "Région Azure pour déployer l'infrastructure"
  default     = "West Europe"
}

# Chemin vers la clé SSH publique
variable "ssh_public_key_path" {
  type        = string
  description = "Chemin vers la clé SSH publique pour l'accès à la VM (~/.ssh/id_rsa.pub)"
}

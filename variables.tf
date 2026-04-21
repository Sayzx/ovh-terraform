# Région AWS
variable "aws_region" {
  type        = string
  description = "Région AWS pour déployer l'infrastructure"
  default     = "eu-west-1" # Irlande
}

# Nom de la paire de clés SSH AWS
variable "ssh_key_name" {
  type        = string
  description = "Nom de la paire de clés SSH AWS existante pour l'accès SSH"
}
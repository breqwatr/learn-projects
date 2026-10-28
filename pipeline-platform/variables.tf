variable "prefix" {
  description = "Prefix for every resource name"
  type        = string
  default     = "ci"
}

variable "domain" {
  description = "Your domain; the platform answers on git.<domain> and ci.<domain>"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address in CIDR form, for example 203.0.113.10/32"
  type        = string
}

variable "external_network" {
  description = "External network that floating IPs come from"
  type        = string
}

variable "linux_image" {
  description = "Name of the Ubuntu 24.04 image"
  type        = string
}

variable "admin_username" {
  description = "Gitea administrator, also the Woodpecker administrator"
  type        = string
  default     = "platform-admin"
}

variable "admin_email" {
  description = "Email address for the Gitea administrator"
  type        = string
}

variable "woodpecker_client" {
  description = "Client ID of the Woodpecker OAuth application in Gitea; empty until you create it"
  type        = string
  default     = ""
}

variable "woodpecker_secret" {
  description = "Client secret of the Woodpecker OAuth application in Gitea"
  type        = string
  default     = ""
  sensitive   = true
}

variable "subnet_cidr" {
  description = "Address range of the platform network"
  type        = string
  default     = "10.40.0.0/24"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/first-instance.pub"
}

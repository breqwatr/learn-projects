variable "prefix" {
  description = "Prefix for every resource name"
  type        = string
  default     = "site"
}

variable "my_ip" {
  description = "Your public IP address in CIDR form; only it can open the site"
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

variable "prefix" {
  description = "Prefix for every resource name"
  type        = string
  default     = "tf"
}

variable "my_ip" {
  description = "Your public IP address in CIDR form, for example 203.0.113.10/32"
  type        = string
}

variable "network_name" {
  description = "Network the instances join"
  type        = string
  default     = "default"
}

variable "external_network" {
  description = "External network that floating IPs come from"
  type        = string
}

variable "linux_image" {
  description = "Name of the Linux image"
  type        = string
}

variable "windows_image" {
  description = "Name of the Windows image"
  type        = string
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/first-instance.pub"
}

variable "linux_flavour" {
  description = "Flavour for the Linux instance"
  type        = string
  default     = "v1.c1r2"
}

variable "prefix" {
  description = "Prefix for every resource name"
  type        = string
  default     = "shop"
}

variable "external_network" {
  description = "External network that floating IPs come from"
  type        = string
}

variable "linux_image" {
  description = "Name of the Ubuntu image"
  type        = string
}

variable "flavour" {
  description = "Flavour for every instance"
  type        = string
  default     = "v1.c1r2"
}

variable "subnet_cidr" {
  description = "Address range of the application network"
  type        = string
  default     = "10.10.0.0/24"
}

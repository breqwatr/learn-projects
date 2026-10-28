variable "name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "flavour" {
  type = string
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
}

variable "key_pair" {
  description = "Key pair name, or null for none"
  type        = string
  default     = null
}

variable "network_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "external_network" {
  type = string
}

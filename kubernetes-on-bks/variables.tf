variable "name" {
  description = "The cluster's name"
  type        = string
  default     = "shop-cluster"
}

variable "cluster_template" {
  description = "The cluster template: the node image and Kubernetes version"
  type        = string
  default     = "debian-13-v1.36.1"
}

variable "worker_count" {
  description = "How many worker nodes"
  type        = number
  default     = 2
}

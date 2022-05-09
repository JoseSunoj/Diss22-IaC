variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "diss-22"
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "diss22-cluster"
}

variable "pool_name" {
  description = "The name for the node pool"
  default     = "diss22-node-pool"
}

variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "prod"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west2"
}

variable "location" {
  description = "The location to host the cluster in"
  default     = "europe-west2-a"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "gke-network"
}

variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}

variable "ip_pods_range_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_svc_range_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}

variable "machine_type" {
  type        = string
  description = "Type of the node compute engines."
  default     = "n1-standard-2"
}

variable "min_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool"
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool"
  default     = 8
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the node's disk."
  default     = 60
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in node_pools."
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 5
}

variable "loadBalancer_IP" {
  type        = string
  description = "loadBalancerIP to istio-ingress service"
  default     = ""
}

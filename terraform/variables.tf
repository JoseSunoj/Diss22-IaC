variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in node_pools."
  default     = "diss22-gke@diss-22.iam.gserviceaccount.com"
}

variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "diss-22"
}

variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "prod"
}

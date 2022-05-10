terraform {
  required_version = ">= 0.14"

  backend "gcs" {
    bucket = "terraform-backend-diss-22"
    prefix = "diss22-terraform"
  }
}

module "prod_cluster" {
  source          = "./main"
  project_id      = var.project_id
  env_name        = var.env_name
  service_account = var.service_account
}


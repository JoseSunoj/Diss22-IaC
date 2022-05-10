terraform {
  required_version = ">= 0.14"

  cloud {
    organization = "Dissertation22"

    workspaces {
      name = "Diss22-IaC"
    }
  }
}

module "prod_cluster" {
  source          = "./main"
  project_id      = var.project_id
  env_name        = var.env_name
  service_account = var.service_account
}


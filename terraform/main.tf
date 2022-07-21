terraform {
  required_version = ">= 0.14"

  required_providers {

    google = {
      source  = "hashicorp/google"
      version = "4.29.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.29.0"
    }

  }

  #backend "remote" {
    #organization = "Dissertation22"
    #workspaces {
     # name = "Diss22-IaC"
    #}
  #}

  backend "gcs" {
    bucket = "terraform-backend-diss-22"
    prefix = "diss22-terraform"
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.location
  credentials = var.gcp-creds
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.location
  credentials = var.gcp-creds
}

module "prod_cluster" {
  source          = "./main"
  project_id      = var.project_id
  env_name        = var.env_name
  service_account = var.service_account
}


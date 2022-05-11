terraform {
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.13.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

  }
}

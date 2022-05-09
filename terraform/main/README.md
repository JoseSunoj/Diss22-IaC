# Terraform Scripts 

Scripts to provision regional private GKE clusters with Istio service mesh and Argocd.

## Prerequisites

    1. A google cloud service account with necessary project roles and activated APIs as explained in  https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster
    
    2. Google cloud CL to interact with GCP (optional)

    3. Latest version of Terraform 

    3. Latest  version of kubectl (optional)

    4. istioctl (optional)

    5. helm (optional)

## Terrafrom commands

Run the following commands to provision the cluster:

    terraform init
    terraform plan
    terraform apply

Note: Details of the service account to be provided when prompted. The manifests folder with the exact path and contents is required to perform the above commands.
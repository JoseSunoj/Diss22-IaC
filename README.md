# GitOps Repo: Pull-based GitOps with Terraform Cloud and Argo CD

## Terraform 

The terraform script can do provisioning of a private GKE cluster with Istio service mesh, Argo CD, and the Microservices Application.

## Terraform Cloud

Monitor this repo for changes in terraform scripts and plan those changes. A DvOps team member with acces to Terraform cloud account can apply those changes.
Auto apply is currently disabled, but can be enabled easily.

## Argo CD

Once the cluster is up and running Argo CD functioning inside the cluster continuously monitor the Main branch of this repo for chnages in the Microservices configuration. 
If the actual state does not match the desired state, it updates the actual state of the infrastructure to match the desired state. 
Now the main branch of this repository is the single source of truth for the Cloud-native application. It is not possible to change its configuration from outside of this repo.

## The Cloud-native e-commerce application 

The application contains a store gateway, and 3 microservices- product, invoice, and notification and is generated using JHipster.

They can be accessed from individual repositories from the links below.

* [store gateway](https://github.com/JoseSunoj/Diss22-Store)
* [product](https://github.com/JoseSunoj/Diss22-Product)
* [invoice](https://github.com/JoseSunoj/Diss22-Invoice)
* [notification](https://github.com/JoseSunoj/Diss22-Notification)


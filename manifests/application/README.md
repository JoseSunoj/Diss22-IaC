# Application Manifests

These manifests were initially generated by Jhipster, but were refactored as per requirements.

## Manifetsts to deploy Jhipster Microservices. 

The kustomization.yml files in the sub directories of base will be updated automatically by the GitHub actions workflow associated with respective application source repositories if the container images were pushed to DockerHub by JIB. 

ArgoCD from the private GKE cluster continuosly polls this repository for changes in app configuration and updates these changes and make sure that the actual and desired states are always in sync.

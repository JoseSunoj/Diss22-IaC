# scripts to provision a private GKE with Istio, Istio addons, Argo CD, and an application

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  load_config_file       = false
}

#  private GKE

module "gke" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                      = var.project_id
  name                            = "${var.cluster_name}-${var.env_name}"
  regional                        = true
  region                          = var.region
  network                         = module.gcp-network.network_name
  subnetwork                      = module.gcp-network.subnets_names[0]
  ip_range_pods                   = var.ip_pods_range_name
  ip_range_services               = var.ip_svc_range_name
  horizontal_pod_autoscaling      = true
  remove_default_node_pool        = true
  enable_binary_authorization     = true
  enable_vertical_pod_autoscaling = true

  node_pools = [
    {
      name               = "diss22-node-pool"
      machine_type       = var.machine_type
      node_locations     = var.location
      min_count          = var.min_count
      max_count          = var.max_count
      disk_size_gb       = var.disk_size_gb
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.service_account
      initial_node_count = var.initial_node_count
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    diss22-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    diss22-node-pool = {

    }
  }

  node_pools_metadata = {
    all = {}

    diss22-node-pool = {

    }
  }

  node_pools_taints = {
    all = []

    diss22-node-pool = [
      {
        key    = "diss22-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    diss22-node-pool = [
      "diss22-node-pool",
    ]
  }

}

# istio with addons
# using separate namespaces for ingress and egress 
# addons are deployed in the namespace istio_system where istiod resides

locals {
  istio_repo = "https://istio-release.storage.googleapis.com/charts"
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  repository      = local.istio_repo
  name            = "istio-base"
  chart           = "base"
  cleanup_on_fail = true
  force_update    = true
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  repository      = local.istio_repo
  name            = "istiod"
  chart           = "istiod"
  cleanup_on_fail = true
  force_update    = true
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "kiali.enabled"
    value = "true"
  }

  set {
    name  = "servicegraph.enabled"
    value = "true"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  depends_on = [helm_release.istio_base]
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"

    labels = {
      istio-injection = "enabled"
    }

  }
}

resource "helm_release" "istio_ingress" {
  repository = local.istio_repo
  name       = "istio-ingressgateway"
  chart      = "gateway"

  cleanup_on_fail = true
  force_update    = true
  namespace       = kubernetes_namespace.istio_ingress.metadata.0.name

  set {
    name  = "service.loadBalancerIP"
    value = var.loadBalancer_IP
  }
  depends_on = [helm_release.istiod]
}

resource "kubernetes_namespace" "istio_egress" {
  metadata {
    name = "istio-egress"

    labels = {
      istio-injection = "enabled"
    }

  }
}

resource "helm_release" "istio_egress" {
  repository = local.istio_repo
  name       = "istio-egressgateway"
  chart      = "gateway"

  cleanup_on_fail = true
  force_update    = true
  namespace       = kubernetes_namespace.istio_egress.metadata.0.name

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  depends_on = [helm_release.istiod]
}

# prometheus, kiali

data "kubectl_path_documents" "addons" {
  pattern = "../manifests/istio/samples/addons/*.yaml"
}

resource "kubectl_manifest" "addons" {
  depends_on = [
    helm_release.istiod, helm_release.istio_ingress, helm_release.istio_egress
  ]
  for_each           = toset(data.kubectl_path_documents.addons.documents)
  yaml_body          = each.value
  override_namespace = "istio-system"
}

# grafana

data "kubectl_file_documents" "addon_grafana" {
  content = file("../manifests/istio/samples/addons/grafana/grafana.yaml")
}

resource "kubectl_manifest" "grafana" {
  depends_on = [
    helm_release.istiod, helm_release.istio_ingress, helm_release.istio_egress
  ]
  count              = length(data.kubectl_file_documents.addon_grafana.documents)
  yaml_body          = element(data.kubectl_file_documents.addon_grafana.documents, count.index)
  override_namespace = "istio-system"
}

# zipkin

data "kubectl_file_documents" "addon_zipkin" {
  content = file("../manifests/istio/samples/addons/extras/zipkin.yaml")
}

resource "kubectl_manifest" "zipkin" {
  depends_on = [
    helm_release.istiod, helm_release.istio_ingress, helm_release.istio_egress
  ]
  count              = length(data.kubectl_file_documents.addon_zipkin.documents)
  yaml_body          = element(data.kubectl_file_documents.addon_zipkin.documents, count.index)
  override_namespace = "istio-system"
}

# Argocd installation with istio patches

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      istio-injection = "enabled"
    }
  }
}

data "kubectl_file_documents" "argocd_install" {
  content = file("../manifests/argocd/argocd-install/argocd-install.yaml")
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.addons, kubectl_manifest.grafana, kubectl_manifest.zipkin, kubernetes_namespace.argocd
  ]
  count              = length(data.kubectl_file_documents.argocd_install.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd_install.documents, count.index)
  override_namespace = "argocd"
}

data "kubectl_path_documents" "argocd_patches" {
  pattern = "../manifests/argocd/argocd-install/argocd-istio/*.yaml"
}

resource "kubectl_manifest" "argocd_patches" {
  depends_on = [
    kubectl_manifest.argocd
  ]
  for_each           = toset(data.kubectl_path_documents.argocd_patches.documents)
  yaml_body          = each.value
  override_namespace = "argocd"
}

# deploying app 
# (this can be done by Argo CD UI or using kubectl from CLI after a succesful terraform apply of the above resources)
# 

data "kubectl_file_documents" "app" {
  content = file("../manifests/argocd/app/application.yaml")
}

resource "kubectl_manifest" "app" {
  depends_on = [
    kubectl_manifest.argocd_patches
  ]
  count              = length(data.kubectl_file_documents.app.documents)
  yaml_body          = element(data.kubectl_file_documents.app.documents, count.index)
  override_namespace = "argocd"
}


############################################
# READ EXISTING AKS CLUSTER
############################################

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group
}

############################################
# KUBERNETES PROVIDER
############################################

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

############################################
# HELM PROVIDER
############################################

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

############################################
# NAMESPACE
############################################

resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}

############################################
# DATADOG API KEY SECRET
############################################

resource "kubernetes_secret" "datadog" {
  metadata {
    name      = "datadog-secret"
    namespace = kubernetes_namespace.datadog.metadata[0].name
  }

  data = {
    api-key = var.datadog_api_key
  }

  type = "Opaque"
}

############################################
# INSTALL DATADOG AGENT
############################################

resource "helm_release" "datadog" {
  name             = "datadog"
  namespace        = "datadog"
  create_namespace = true

  repository = "https://helm.datadoghq.com"
  chart      = "datadog"

  values = [
    file("${path.module}/datadog-values.yaml")
  ]

  set {
    name  = "datadog.clusterName"
    value = var.aks_cluster_name
  }

  depends_on = [
    kubernetes_secret.datadog
  ]
}


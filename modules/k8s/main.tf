locals {
  common_labels = merge({
    app = "httpbin"
  }, var.labels)
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
    labels = local.common_labels
  }
}

resource "kubernetes_deployment" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "httpbin"
      }
    }

    template {
      metadata {
        labels = local.common_labels
      }
      spec {
        container {
          name  = "httpbin"
          image = var.image

          port {
            name           = "http"
            container_port = var.container_port
          }

          liveness_probe {
            http_get {
              path = "/status/200"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/get"
              port = var.container_port
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    selector = {
      app = "httpbin"
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.container_port
      node_port   = var.service_type == "NodePort" ? var.node_port : null
    }

    type = var.service_type
  }
}

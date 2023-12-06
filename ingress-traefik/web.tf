resource "kubernetes_service" "this" {
  count = var.create_service ? 1 : 0
  metadata {
    namespace = var.namespace
    name      = local.service.name
  }

  spec {
    port {
      name = local.service.port_name
      port = var.app.port
    }

    selector = { app = var.app.name }
  }
}

resource "kubernetes_manifest" "cors" {
  count = var.cors == null ? 0 : 1
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      namespace = var.namespace
      name      = "${local.service.name}-cors"
    }
    spec = {
      headers = {
        accessControlAllowMethods    = var.cors.methods
        accessControlAllowHeaders    = ["*"]
        accessControlAllowOriginList = var.cors.origins
        accessControlMaxAge          = 100
        addVaryHeader                = true
      }
    }
  }
}

locals {
  middlewares = compact([
    var.cors == null ? "" : "${var.namespace}-${kubernetes_manifest.cors[0].manifest.metadata.name}@kubernetescrd",
  ])

  middleware_annotations = merge(
    length(local.middlewares) == 0 ? {} : {
      "traefik.ingress.kubernetes.io/router.middlewares" = join(",", local.middlewares)
    }
  )
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    namespace = var.namespace
    name      = "${local.service.name}-ingress"
    annotations = merge({
      "cert-manager.io/cluster-issuer" = var.issuer
      "kubernetes.io/ingress.class"    = "traefik"
    }, local.middleware_annotations)
  }

  spec {
    tls {
      hosts       = var.tls.hosts
      secret_name = var.tls.secret_name
    }

    rule {
      host = var.domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = local.service.name
              port { name = local.service.port_name }
            }
          }
        }
      }
    }
  }
}

output "service_host" {
  value       = "${local.service.name}.${var.namespace}.svc.cluster.local:${var.app.port}"
  description = "service host used in kubernetes"
}

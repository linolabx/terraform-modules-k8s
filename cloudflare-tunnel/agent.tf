variable "agent" {
  type = object({
    namespace     = string
    replicas      = number
    node_selector = map(string)
  })
  default = null
}

resource "kubernetes_deployment" "cloudflared" {
  count = var.agent != null ? 1 : 0

  metadata {
    name      = "cloudflared"
    namespace = var.agent.namespace
    labels    = { app = "cloudflared" }
  }

  spec {
    replicas = var.agent.replicas

    selector { match_labels = { pod = "cloudflared" } }

    template {
      metadata { labels = { pod = "cloudflared" } }

      spec {
        node_selector = var.agent.node_selector
        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:latest"

          command = [
            "cloudflared",
            "tunnel",
            "--metrics",
            "0.0.0.0:80",
            "run",
            "--token",
            cloudflare_tunnel.this.tunnel_token
          ]
          liveness_probe {
            http_get {
              path = "/ready"
              port = 80
            }
            failure_threshold     = 1
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "cloudflared" {
  count = var.agent != null ? 1 : 0

  metadata {
    name      = "cloudflared"
    namespace = var.agent.namespace
    labels    = { app = "cloudflared" }
  }

  spec {
    selector = { pod = "cloudflared" }
    port {
      name        = "metrics"
      port        = 80
      target_port = 80
    }
  }
}

output "agent_metrics_url" {
  value = var.agent != null ? "http://${kubernetes_service.cloudflared.0.metadata.0.name}.${kubernetes_service.cloudflared.0.metadata.0.namespace}.svc.cluster.local" : null
}

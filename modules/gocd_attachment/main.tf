resource "kubernetes_namespace" "gocd" {
  metadata {
    name = "gocd"
  }
}

resource "kubernetes_deployment" "gocd_server" {
  provider = kubernetes
  metadata {
    name      = "gocd-server"
    namespace = kubernetes_namespace.gocd.metadata[0].name
    labels = {
      app = "gocd-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gocd-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "gocd-server"
        }
      }

      spec {
        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }
        container {
          name  = "gocd-server"
          image = "gocd/gocd-server:v23.2.0"
          port {
            container_port = var.gocd_server_port
          }
          volume_mount {
            mount_path = "/home/go"
            name       = "gocd-server-storage"
          }
          env {
            name  = "GOCD_PLUGIN_INSTALL_github-oath-authorization-plugin"
            value = "https://github.com/gocd-contrib/github-oauth-authorization-plugin/releases/download/v3.4.0-281/github-oauth-authorization-plugin-3.4.0-281.jar"
          }
        }



        volume {
          name = "gocd-server-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.server_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gocd_server_service" {
  metadata {
    name      = "gocd-server-service"
    namespace = kubernetes_namespace.gocd.metadata[0].name
  }

  spec {
    selector = kubernetes_deployment.gocd_server.metadata[0].labels
    port {
      port        = 80
      target_port = var.gocd_server_port
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "gocd_agent" {
  provider = kubernetes
  metadata {
    name      = "gocd-agent"
    namespace = kubernetes_namespace.gocd.metadata[0].name
    labels = {
      app = "gocd-agent"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gocd-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "gocd-agent"
        }
      }

      spec {
        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }
        container {
          name  = "gocd-agent"
          image = "gocd/gocd-agent-alpine-3.18:v23.2.0"

          env {
            name  = "GO_SERVER_URL"
            value = "http://dualstack.${kubernetes_service.gocd_server_service.status.0.load_balancer.0.ingress.0.hostname}/go"
          }
          volume_mount {
            mount_path = "/home/go"
            name       = "gocd-agent-storage"
          }
        }

        volume {
          name = "gocd-agent-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.agent_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

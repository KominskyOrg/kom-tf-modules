resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    fsType    = "ext4"
    encrypted = "true"
  }
}

resource "kubernetes_persistent_volume_claim" "server_pvc" {
  metadata {
    name      = "${var.cluster_name}-gocd-server-pvc"
    namespace = "gocd"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.ebs_sc.metadata.0.name
  }
}

resource "kubernetes_persistent_volume_claim" "agent_pvc" {
  metadata {
    name      = "${var.cluster_name}-gocd-agent-pvc"
    namespace = "gocd"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.ebs_sc.metadata.0.name
  }
}

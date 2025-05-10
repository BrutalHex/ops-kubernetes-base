resource "kubernetes_storage_class" "ebs_gp2" {
  metadata {
    name = "ebs-gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"
}

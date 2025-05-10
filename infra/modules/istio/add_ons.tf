
resource "null_resource" "install_prometheus" {
  depends_on = [null_resource.install_prometheus]
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      curl -H "Accept: application/octet-stream" -L -o ${path.module}/prometheus.yaml https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/prometheus.yaml
      kubectl apply --server-side -f ${path.module}/prometheus.yaml
    EOT
  }
}


resource "helm_release" "kiali-server" {
  depends_on = [kubernetes_namespace.istio-namespace, helm_release.istio-base, helm_release.istio-d]
  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = kubernetes_namespace.istio-namespace.metadata[0].name
  values = [yamlencode({
    auth = {
      strategy = "anonymous"
    }
  })]
}
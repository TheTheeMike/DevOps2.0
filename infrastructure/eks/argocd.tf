# ArgoCD Installation
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.0"
  namespace  = "argocd"

  create_namespace = true

  values = [
    <<-EOT
    server:
      service:
        type: LoadBalancer
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - argocd.student1.devops1.test-danit.com
        tls:
          - secretName: argocd-tls
            hosts:
              - argocd.student1.devops1.test-danit.com
      extraArgs:
        - --insecure
    configs:
      params:
        server.insecure: true
    EOT
  ]

  depends_on = [helm_release.nginx_ingress]
}

# Get ArgoCD admin password
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value     = nonsensitive(data.kubernetes_secret.argocd_admin_password.data.password)
  sensitive = false
}

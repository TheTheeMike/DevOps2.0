module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnet_ids = ["subnet-093006bef8b944304", "subnet-0a1abdcb974978c80"]
  vpc_id     = "vpc-075e67aa7f86c569a"

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      min_size     = 1
      max_size     = 1

      instance_types = ["t3.small"]
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true

  depends_on = [module.eks]
}
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  create_namespace = true

  values = [<<EOF
server:
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - argocd.student1.devops1.test-danit.com
EOF
]

  depends_on = [
    module.eks,
    helm_release.nginx_ingress
  ]
}


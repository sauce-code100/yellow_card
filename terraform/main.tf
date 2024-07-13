data "aws_eks_cluster" "cluster" {
  name = var.cluster_name  
}


data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}


resource "helm_release" "my_app" {
  name       = var.app_name
  repository = "https://raw.githubusercontent.com/swiftDev1/yellow_card/develop/"
  chart      = "deployment-chart"
  version    = "1.0.0"
  values     = [file("${path.module}/deployment-values.yaml")]
  namespace = var.namespace
}

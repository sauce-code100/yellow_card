variable "app_name" {
  description = "Name of the application to be deployed by heml chart"
  type    = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy resources to" 
  type    = string
  default = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type    = string
}

variable "aws_region" {
  description = "AWS region you want to deploy your resources to"  
  type = string
  default = "us-east-1"
}
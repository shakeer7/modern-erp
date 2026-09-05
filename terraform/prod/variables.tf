variable "region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "name" {
  description = "Resource name prefix."
  type        = string
  default     = "college-app"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "college-app-cluster"
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.30.0.0/16"
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs."
  type        = list(string)
  default     = ["10.30.0.0/20", "10.30.16.0/20", "10.30.32.0/20"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs."
  type        = list(string)
  default     = ["10.30.128.0/20", "10.30.144.0/20", "10.30.160.0/20"]
}

variable "single_nat_gateway" {
  description = "One NAT gateway per AZ for high availability in prod."
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "Managed node group instance types."
  type        = list(string)
  default     = ["c7i-flex.large"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "ecr_frontend_repository_name" {
  description = "ECR repository holding frontend images."
  type        = string
  default     = "college-frontend"
}

variable "ecr_auth_repository_name" {
  description = "ECR repository holding auth service images."
  type        = string
  default     = "college-auth"
}
variable "ecr_market_repository_name" {
  description = "ECR repository holding market service images."
  type        = string
  default     = "college-market"
}

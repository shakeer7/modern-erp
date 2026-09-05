# Dev environment: full AWS foundation for the platform.

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "../modules/vpc"

  name               = var.name
  cidr               = var.vpc_cidr
  azs                = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  cluster_name       = var.cluster_name
  single_nat_gateway = var.single_nat_gateway
}

module "iam" {
  source = "../modules/iam"

  name = var.name
}

module "eks" {
  source = "../modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn

  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
}

module "ecr_frontend" {
  source          = "../modules/ecr"
  repository_name = var.ecr_frontend_repository_name
}

module "ecr_auth" {
  source          = "../modules/ecr"
  repository_name = var.ecr_auth_repository_name
}

module "ecr_market" {
  source          = "../modules/ecr"
  repository_name = var.ecr_market_repository_name
}

resource "aws_s3_bucket" "market_images" {
  bucket = "${var.name}-market-images-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "market_images_ownership" {
  bucket = aws_s3_bucket.market_images.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "market_images_public_access" {
  bucket = aws_s3_bucket.market_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "market_images_policy" {
  bucket     = aws_s3_bucket.market_images.id
  depends_on = [aws_s3_bucket_public_access_block.market_images_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.market_images.arn}/*"
      },
    ]
  })
}

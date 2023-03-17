
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "archive" {}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "minecraft"
      DeployedBy  = "Terraform"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "minecraft"
      DeployedBy  = "Terraform"
    }
  }
}

module "minecraft" {
  source = "../minecraft"
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
  region        = "us-east-1"
  account       = "1234567890"
  vpc_id        = "vpc-abcd1234"
  domain_name   = "example.com"
  cluster_name  = "minecraft"
  service_name  = "minecraft-server"
  s3_bucket_arn = "arn:aws:s3:::example-com-us-east-1"
}

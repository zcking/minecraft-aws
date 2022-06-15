variable "region" {
  type        = string
  description = "AWS region to deploy minecraft server to"
  default     = "us-east-1"
}

variable "account" {
  type        = string
  description = "Your AWS account number"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID that ECS will run in. Must contain at least one subnet"
}

variable "domain_name" {
  type        = string
  description = "Your registered domain name managed in Route53"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket that will be used for pushing game files to from EFS"
}

variable "cluster_name" {
  type        = string
  description = "What to name the ECS cluster"
  default     = "minecraft"
}

variable "service_name" {
  type        = string
  description = "What to name the ECS service"
  default     = "minecraft-server"
}

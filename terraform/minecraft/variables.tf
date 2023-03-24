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

variable "extra_minecraft_server_env_vars" {
  type        = map
  description = "Environment variables to configure on the ecs-task for the minecraft-server container"
  default = {}
}

variable "minecraft_server_cpu" {
  type = number
  description = "Configures ecs-task vCPU where 1024 = 1 vCPU"
  default = 1024
}

variable "minecraft_server_memory" {
  type = number
  description = "Configures ecs-task memory where 2048 = 2 GB"
  default = 2048
}

variable "ecs_service_enable_execute_command" {
  type= bool
  description = "Allows you to aws ecs execute-command into the container instances, ecs-task IAM Role requires AmazonSSMManagedInstanceCore policy"
  default = false
}

variable "extra_ingresses" {
  type = list(
    object({
      protocol  = string
      from_port = number 
      to_port   = number 
      cidr_blocks = list(string)
    })
  )
  description = "Used to enable mods like simple-voice-chat mod or hosted journeymap"
  default = [ ]
}
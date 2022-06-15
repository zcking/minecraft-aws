# Minecraft AWS On-Demand

This project is my implementation of the following guide, but with the infrastructure 
code written and managed using Hashicorp Terraform:  https://github.com/doctorray117/minecraft-ondemand 

## Quick Start

Make sure you have installed Terraform 1.x or above. 

Then edit the [./terraform/example/main.example.tf](./terraform/example/main.example.tf)
and change the following variables to your liking:  

``` 
  region        = "us-east-1"
  account       = "1234567890"
  vpc_id        = "vpc-abcd1234"
  domain_name   = "example.com"
  cluster_name  = "minecraft"
  service_name  = "minecraft-server"
  s3_bucket_arn = "arn:aws:s3:::example-com-us-east-1"
```

Then, from that directory, run `terraform init` and `terraform apply` to plan and create the infrastructure. 


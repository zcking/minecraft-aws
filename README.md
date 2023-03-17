# Minecraft AWS On-Demand

This project is my implementation of the following guide, but with the infrastructure 
code written and managed using Hashicorp Terraform:  https://github.com/doctorray117/minecraft-ondemand 

> **Key Difference!** I modified the original architecture slightly for security reasons. 
> Instead of having the server startup be triggered by a DNS query, I have set up 
> Amazon Simple Email Service (SES) to be able to receive mail using a domain name
> registered with Amazon Route53.
>
> This project will automatically create the `MX` DNS record and SES setup. To start your
> Minecraft server, simply send an email, any email, to `minecraft-start@<yourdomain>.com`.
>
> You can customize this address in the [./terraform/minecraft/ses.tf](./terraform/minecraft/ses.tf)
> file, or even modify the Python lambda function to look for a passphrase in the email body!

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


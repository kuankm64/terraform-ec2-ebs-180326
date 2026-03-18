terraform {
    required_version = ">= 1.10"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 6.34.0"
      }
    }
  backend "s3" {
    bucket = "sctp-ce12-tfstate-bucket"      #Change to your S3 bucket name, e.g. sctp-ce12-tfstate-bucket
    key    = "kuankm-24-ec2-example/terraform.tfstate" #Path within the bucket, e.g. ec2-example/terraform.tfstate
    region = "ap-southeast-1"                #Change to your S3 bucket region, e.g., ap-southeast-1
  }
}
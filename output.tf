output "my_vpc_id" {
  description = "The ID of the VPC created by the module"
  value       = module.vpc.vpc_id
}

output "ami_id" {
  description = "The AMI ID used for the instances"
  value       = data.aws_ami.amazon_linux.id
}

output "subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# Returns an array of all Public DNS names
output "instance_public_dns" {
  description = "Public DNS of all EC2 instances"
  value       = aws_instance.public_ec2[*].public_dns
}

# Returns an array of all Public IPs
output "instance_public_ip" {
  description = "Public IP of all EC2 instances"
  value       = aws_instance.public_ec2[*].public_ip
}

# Returns an array of all Volume IDs
output "volume_ids" {
  description = "IDs of the attached EBS volumes"
  value       = aws_ebs_volume.extra_storage[*].id
}
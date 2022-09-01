variable "aws_region" {
  description = "Set AWS service region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Set AWS IAM profile"
  type        = string
}


variable "vpc_settings" {
  description = "Set VPC settings name and CIDR Block"
  type = object({
    name         = string
    cidr_block   = string
    gateway_name = string
  })
}

variable "subnet_settings" {
  description = "Set VPC Subnet name and CIDR Block for EC2 instance"
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "ec2_settings" {
  description = "Set EC2 instance settings"
  type = object({
    name          = string
    key_pair      = string
    key_pair_path = string
    aim_owners    = list(string)
    aim_names     = list(string)
    instance_type = string
  })
}

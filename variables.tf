variable "region" {
  type        = string
  description = "The AWS region to deploy resources in"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC Cidr block"
}

variable "aws_stack_name" {
  type        = string
  description = "Project name"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "availability_zones" {
  description = "List of availability zones to be used"
  type        = list(string)
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}
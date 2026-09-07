variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "msa-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where fck-nat will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID to place the fck-nat instance"
  type        = string
}

variable "private_route_table_id" {
  description = "Private Route Table ID to route outbound traffic through fck-nat"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for fck-nat (t4g.nano for ARM64 cost saving)"
  type        = string
  default     = "t4g.nano"
}


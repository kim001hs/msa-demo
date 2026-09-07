variable "aws_region" {
  description = "AWS Region to deploy bootstrap resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "msa-demo"
}


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

variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
  default     = "kim001hs/msa-demo"
}


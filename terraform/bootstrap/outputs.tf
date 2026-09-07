output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.tfstate.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created for Terraform state lock"
  value       = aws_dynamodb_table.tflock.name
}

output "backend_snippet" {
  description = "Terraform backend configuration block to paste into envs/dev/backend.tf"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tfstate.id}"
        key            = "envs/dev/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.tflock.name}"
        encrypt        = true
      }
    }
  EOT
}


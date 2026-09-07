resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 1. S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.project_name}-tfstate-${random_string.suffix.result}"
  force_destroy = true # 실습용이므로 destroy 용이하게 설정

  tags = {
    Name        = "${var.project_name}-tfstate"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

# 버전 관리 활성화 (이전 상태 복구 가능)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 기본 서버 측 암호화 (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "tflock" {
  name         = "${var.project_name}-tflock"
  billing_mode = "PAY_PER_REQUEST" # 온디맨드 과금 (비용 거의 $0)
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-tflock"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}


# 현재 AWS 계정 및 리전 정보 조회
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# 사용 가능한 가용 영역(AZ) 목록 조회 (상태가 available인 AZ만 필터링)
data "aws_availability_zones" "available" {
  state = "available"
}


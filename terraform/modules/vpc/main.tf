# 1. VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-vpc"
    Environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# 2. 인터넷 게이트웨이 (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

# 3. Public Subnets (2개 AZ 분산)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    "kubernetes.io/role/elb"                    = "1" # AWS Load Balancer Controller가 퍼블릭 ALB를 배치하기 위한 필수 태그
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# 4. Private Subnets (2개 AZ 분산 - EKS 노드 및 파드 배치용)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    "kubernetes.io/role/internal-elb"           = "1" # 내부 로드 밸런서 배치용 필수 태그
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# 5. Public Route Table & IGW 라우트
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. Private Route Table (fck-nat 모듈에서 0.0.0.0/0 라우트를 추가함)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


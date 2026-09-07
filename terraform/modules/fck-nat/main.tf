# 1. fck-nat 최신 공식 ARM64 AMI 검색
data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["568608671756"] # fck-nat 공식 오픈소스 배포 계정

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*-arm64-ebs", "fck-nat-amzn2-*-arm64-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# 2. fck-nat 보안 그룹 (Private Subnet의 모든 아웃바운드 인터넷 요청 중계)
resource "aws_security_group" "fck_nat" {
  name        = "${var.project_name}-${var.environment}-fck-nat-sg"
  description = "Security Group for fck-nat instance"
  vpc_id      = var.vpc_id

  # VPC 내부에서 오는 모든 트래픽 허용 (NAT 역할)
  ingress {
    description = "Allow all inbound from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # 외부 인터넷으로 나가는 모든 아웃바운드 허용
  egress {
    description = "Allow all outbound to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-fck-nat-sg"
    Environment = var.environment
  }
}

# 3. fck-nat EC2 인스턴스 (t4g.nano ARM64 초경량 인스턴스)
resource "aws_instance" "fck_nat" {
  ami                    = data.aws_ami.fck_nat.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.fck_nat.id]

  # NAT 인스턴스의 핵심: 자신을 목적지로 하지 않는 패킷도 포워딩하도록 소스/대상 확인 비활성화
  source_dest_check = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-fck-nat"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 4. 탄력적 IP (EIP) 할당 및 fck-nat 연결
resource "aws_eip" "fck_nat" {
  domain   = "vpc"
  instance = aws_instance.fck_nat.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-fck-nat-eip"
    Environment = var.environment
  }
}

# 5. Private 서브넷의 0.0.0.0/0 기본 라우트를 fck-nat의 ENI로 연결
resource "aws_route" "private_nat_gateway" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.fck_nat.primary_network_interface_id
}


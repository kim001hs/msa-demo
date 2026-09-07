# 1. EKS 클러스터 컨트롤 플레인 생성
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    # 클러스터 ENI는 Public과 Private 서브넷을 모두 연결하여 유연한 엔드포인트 통신 보장
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

# 2. EKS Managed Node Group (AWS Graviton ARM64)
resource "aws_eks_node_group" "graviton" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-graviton-ng"
  node_role_arn   = aws_iam_role.node_group.arn

  # 보안을 위해 워커 노드는 반드시 Private Subnet에만 배치
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Graviton 사양: ARM64 및 Amazon Linux 2023 AMI
  instance_types = var.node_instance_types # ["t4g.large"]
  ami_type       = "AL2023_ARM_64_STANDARD"
  capacity_type  = var.node_capacity_type # "ON_DEMAND" 또는 "SPOT"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Name        = "${var.cluster_name}-graviton-node"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


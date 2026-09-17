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

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

# 2. EKS Managed Node Group (x86_64 t3.large)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-default-ng"
  node_role_arn   = aws_iam_role.node_group.arn

  # 보안을 위해 워커 노드는 반드시 Private Subnet에만 배치
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # x86_64 사양: Amazon Linux 2023 AMI
  instance_types = var.node_instance_types # ["t3.large"]
  ami_type       = "AL2023_x86_64_STANDARD"
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
    Name        = "${var.cluster_name}-default-node"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# GitHub Actions가 destroy 전에 모든 namespace의 LoadBalancer Service를 정리할 수 있도록 허용
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_actions_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_edit" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "cluster"
  }
}

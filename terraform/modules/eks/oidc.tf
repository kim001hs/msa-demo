# EKS 클러스터의 OIDC Issuer URL로부터 TLS 인증서 정보 조회
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# IAM OpenID Connect Provider 생성 (IRSA 활성화)
# 파드가 AWS 자격증명(Access Key) 없이 IAM Role을 임시로 획득(AssumeRoleWithWebIdentity)할 수 있게 해줌
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.cluster_name}-oidc-provider"
    Environment = var.environment
  }
}


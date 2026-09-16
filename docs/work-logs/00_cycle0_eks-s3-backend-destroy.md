# 📝 [Cycle-0] EKS v1.36 배포, Online Boutique 기동, S3 원격 백엔드 마이그레이션 & Actions Destroy 구축

> **핵심 목표:** AWS EKS 클러스터 v1.36 및 Online Boutique 12개 파드 정상 배포(Cycle 0)를 완수하고, S3 원격 백엔드 이전 및 과금 방어용 원클릭 GitHub Actions Destroy 파이프라인 구축  
> **상태:** ✅ 완료  
> **관련 아키텍처:** [architecture.md](../infra-project/architecture.md)

---

## 1. 🎯 배경 및 목표

1. **EKS 버전 정합성 확보:**
   - 기존 설정의 Kubernetes `1.37` 버전은 AWS 서울(ap-northeast-2) 리전에서 아직 미지원되어 배포 실패 발생.
   - 현재 최신 안정 지원 버전인 `1.36`으로 다운그레이드하여 정상 프로비저닝 완수.
2. **Online Boutique 마이크로서비스 기동 (Cycle 0 완수):**
   - 11개 MSA 서비스와 인클러스터 Redis 캐시, 부하 생성기를 Helm으로 배포하여 베이스라인 애플리케이션 확보.
3. **인프라 원격 상태(State) 보호:**
   - 로컬 `terraform.tfstate`에 의존하던 구조를 AWS S3 버킷 + DynamoDB 분산 잠금(Locking) 구조로 마이그레이션.
4. **FinOps 비용 방어 (원클릭 파괴 파이프라인):**
   - 퇴근길 스마트폰 또는 웹에서 원클릭으로 클러스터와 노드를 완전히 파괴(`terraform destroy`)할 수 있는 GitHub Actions 워크플로우 구성.
   - AWS 영구 Access Key 없이 안전하게 통신하기 위한 IAM OIDC Provider 및 역할(Role) 배포.

---

## 2. 🛠️ 주요 구현 및 변경 내역

### 1) EKS 인프라 및 애플리케이션 배포
- **EKS v1.36 클러스터:** `msa-demo-dev-eks` 프로비저닝 (VPC, fck-nat, 퍼블릭 서브넷 2개, 프라이빗 서브넷 2개).
- **워커 노드:** 2x `t3.large` (x86_64 amd64) 노드 정상 준비 완료 (`Ready`).
- **Online Boutique 12개 파드 정상 기동:**
  - `adservice`, `cartservice`, `checkoutservice`, `currencyservice`, `emailservice`, `frontend`, `loadgenerator`, `paymentservice`, `productcatalogservice`, `recommendationservice`, `redis-cart`, `shippingservice` (전부 `1/1 Running`).

### 2) S3 원격 백엔드 & DynamoDB Lock 이전
- `terraform/bootstrap/main.tf`: S3 버킷(`msa-demo-tfstate-ssouyy`) 및 DynamoDB 테이블(`msa-demo-tflock`) 배포.
- `terraform/envs/dev/backend.tf`: S3 백엔드 구성 활성화.
- `terraform init -migrate-state`: 로컬 63KB 크기의 EKS 상태 파일을 S3로 안전하게 이전 완료.

### 3) GitHub Actions OIDC 및 Destroy 자동화
- `terraform/bootstrap/oidc_github.tf`: GitHub OIDC Provider 및 `msa-demo-github-actions-role` IAM 역할 배포.
- `.github/workflows/terraform_destroy.yaml`: `workflow_dispatch` 트리거 기반 원클릭 삭제 워크플로우 추가 (Fallback `terraform.tfvars` 자동 복사 포함).

### 4) CI/CD 워크플로우 및 템플릿 일원화
- 구글 내부 레거시 워크플로우 11개 및 불필요한 봇 설정 34개 파일 정리.
- `.github/pull_request_template.md`: 엔지니어링 표준 한/영 구조화 PR 템플릿 구축.
- `.github/code_review_template.md`: EKS v1.36 규격 기반 사전 점검 가이드 및 댓글 분리형 서식 구축.
- `.github/smart_commit.md`: 단일 타겟 `main` 기반 GitHub Flow 및 **다중 주제(Multi-Topic: 인프라 vs CI) 감지 시 독립 브랜치/다중 PR 분할 워크플로우** 탑재.

---

## 3. 🚨 트러블슈팅 & 기술적 의사결정 (Troubleshooting & ADR)

### 📌 이슈 1: AWS EKS v1.37 미지원 오류
- **증상:** `terraform apply` 실행 시 `InvalidParameterException: unsupported Kubernetes version 1.37` 오류와 함께 배포 즉시 중단.
- **원인:** AWS 서울 리전에서는 현재 Kubernetes v1.36까지만 정식 지원됨.
- **해결:**
  - `terraform.tfvars`, `variables.tf`, `modules/eks/variables.tf`, `README.md`, `architecture.md`의 EKS 버전을 `1.37` ➡️ `1.36`으로 일괄 수정 후 재배포 성공.
- **교훈:** EKS 버전 선정 시 AWS 공식 릴리즈 노트를 사전에 교차 검증하고, Terraform 기본값에 항상 호환성 테스트가 완료된 버전을 명시할 것.

### 📌 이슈 2: IAM OIDC Provider 신뢰 관계 ARN 문법 오류
- **증상:** `terraform/bootstrap`에서 OIDC 역할 생성 시 `MalformedPolicyDocument: Federated principals must be valid domain names or SAML metadata ARNs` 발생.
- **원인:** ARN 문자열 조합 중 `arn:aws:iam//818719120165:...` 형태로 쌍슬래시(`//`)가 삽입됨.
- **해결:** `arn:aws:iam::${account_id}:oidc-provider/...`로 콜론(`::`) 형식으로 수정하여 즉시 해결.

### 📌 이슈 3: S3 버킷 고유성(Uniqueness) 확보
- **의사결정:** S3 버킷 네임스페이스 충돌을 방지하기 위해 `random_string.suffix`를 붙여 `msa-demo-tfstate-ssouyy`로 안전하게 버킷을 생성.

### 📌 이슈 4: 인프라 수정과 CI 템플릿 개편의 단일 커밋 혼재 방지
- **의사결정:** 인프라 변경(IaC)과 템플릿 변경(CI/CD)은 영향 범위와 리뷰어가 다르므로 한 커밋이나 한 PR에 섞이지 않도록, `smart_commit.md`에 다중 브랜치 분할 전략(1-A)을 신설하고 실제로 2개의 독립 PR로 분리 발행함.

---

## 4. 🔗 주요 산출물 및 검증 결과

### 📦 산출물 링크
- **인프라 마일스톤 PR:** [PR #6: feat(infra): EKS v1.36 다운그레이드 및 S3 원격 백엔드 마이그레이션](https://github.com/kim001hs/msa-demo/pull/6) (Issue #5 연결)
- **CI/CD 마일스톤 PR:** [PR #8: feat(ci): GitHub Actions Destroy 워크플로우 추가 및 PR/코드리뷰 템플릿 일원화](https://github.com/kim001hs/msa-demo/pull/8) (Issue #7 연결)
- **원클릭 삭제 워크플로우:** [.github/workflows/terraform_destroy.yaml](../../.github/workflows/terraform_destroy.yaml)
- **AI 워크플로우 지침:** [.github/smart_commit.md](../../.github/smart_commit.md)

### 🧪 검증 결과 (Verification)
- **EKS 노드 상태:**
  ```text
  NAME                                                STATUS   ROLES    AGE   VERSION
  ip-10-0-10-74.ap-northeast-2.compute.internal      Ready    <none>   1h    v1.36.0-eks-...
  ip-10-0-11-213.ap-northeast-2.compute.internal     Ready    <none>   1h    v1.36.0-eks-...
  ```
- **Online Boutique 파드 상태:** 12/12 파드 정상 `Running` 확인
- **S3 상태 파일 보관 확인:**
  ```bash
  aws s3 ls s3://msa-demo-tfstate-ssouyy/envs/dev/
  # 2026-09-16  63.2 KiB  terraform.tfstate  (정상 업로드 확인)
  ```

---

## 5. ⏭️ 다음 마일스톤 연결 (Next Steps)
- **[퇴근 FinOps]:** GitHub Actions에서 `Terraform Destroy` 실행하여 클러스터 \$0 정리
- **[Cycle 1]:** Observability 인프라 구축 (Prometheus, Grafana, Loki, Tempo, OpenTelemetry) 착수

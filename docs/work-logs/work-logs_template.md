# 📝 [Cycle-X] 사이클 명칭 (검증 가능한 단일 가치 요약)

> **반복 주기 (Iteration):** Cycle X  
> **수행 기간 (Period):** YYYY-MM-DD ~ YYYY-MM-DD (약 2주)  
> **SDLC 생명주기:** 계획(Plan) ➡️ 설계(Design) ➡️ 구현(Implementation) ➡️ 검증(V&V) ➡️ 회고(Retrospective)  
> **마일스톤 상태:** ✅ 완료 (또는 ⏳ 진행 중)  
> **핵심 증명 가치 (Working Increment):** (이번 2주 주기가 끝났을 때 "실제로 처음부터 끝까지 동작하고 검증할 수 있게 된 파이프라인/결과물" 1~2줄 요약)  
> *(예: "AWS 인프라 프로비저닝 + 마이크로서비스 연동 + 기본 모니터링 + Locust 부하 테스트를 결합하여 개발 환경 E2E 트래픽 흐름을 정상 검증 완료")*

---

> 💡 **사이클 작성 원칙 (Vertical Slice - 수직적 관통):**  
> '인프라만 구축'하거나 '모니터링만 추가'하는 수평적 분절은 사이클이 아닌 세부 작업(Task)입니다.  
> 얇더라도 **[인프라 ➡️ 서비스 연결 ➡️ 모니터링 ➡️ 테스트]**까지 한 세트를 완성하여, 사이클 종료 시점에 **"그래서 무엇을 증명/측정했는가?"**에 답할 수 있는 완결된 결과를 기록합니다.

---

## 1. 🎯 사이클 목표 및 요구사항 (Goal & Requirements)

### 📌 검증 가능한 가치 (Working Increment Goal)
- 이번 2주 사이클을 통해 시스템이 최종적으로 증명해야 하는 기술적 목표:
  - (예: "동기 통신 환경에서 부하 발생 시의 지연 병목 지표를 수집하고, 비동기 메시지 큐 도입을 위한 기준선을 수립한다.")

### 📌 기능 요구사항 (FR - Functional Requirements)
- 수직 관통 파이프라인 완성을 위해 충족해야 할 동작:
  - [ ] FR-1: (예: Terraform 기반 AWS EKS 및 VPC 프로비저닝)
  - [ ] FR-2: (예: 핵심 마이크로서비스 및 캐시 계층 Helm 배포 및 상호 연동)
  - [ ] FR-3: (예: 부하 생성기(Locust) 연동을 통한 테스트 트래픽 발생)

### 📌 비기능 요구사항 (NFR - Non-Functional Requirements)
- **비용 (FinOps):** 유휴 비용 차단 전략, 원클릭 삭제 파이프라인, 리소스 사이징
- **보안 (Security):** OIDC 임시 자격증명, 최소 권한 원칙(Least Privilege), 네트워크 격리
- **안정성 및 성능 (Reliability & Performance):** 무중단 복구, 상태 잠금, 타임아웃/재시도 정책

---

## 2. 🏗️ 기술적 의사결정 (ADR - Architecture Decision Records)

### 📌 ADR-01: [의사결정 주제 (예: 비동기 큐 도입에 따른 AWS SQS vs Self-Hosted RabbitMQ)]
- **문제 맥락 (Context):** 해결하고자 하는 병목이나 기술적 제약사항
- **대안 검토 (Options Considered):**
  - 대안 A: (장점 / 단점 / 운영 비용)
  - 대안 B: (장점 / 단점 / 운영 비용)
- **결정 및 엔지니어링 근거 (Decision & Rationale):** 채택한 대안과 기술적 트레이드오프 분석
- **파급 효과 (Consequences):** 이번 결정이 시스템 아키텍처 및 다음 사이클에 미치는 영향

---

## 3. 🛠️ 수직 관통 구현 상세 (Vertical Slice Implementation)

> 하나의 완결된 파이프라인을 이루는 4단계 세부 구현 내역을 기록합니다.

### Step 1. 인프라 & 리소스 프로비저닝 (Infra / IaC)
- [ ] **IaC 구성:** (예: Terraform으로 네트워크, 클러스터, 데이터베이스, IAM 등 프로비저닝)
- [ ] **상태 및 비밀 관리:** (예: S3 백엔드 상태 잠금, Secrets Manager 연동)

### Step 2. 애플리케이션 및 파이프라인 연결 (App & Integration)
- [ ] **서비스 패키징 & 배포:** (예: Helm Chart 구성, 파드 배포, Config/Secret 주입)
- [ ] **서비스 간 연결 (E2E Integration):** (예: 서비스 디스커버리, 인그레스 라우팅, 메시지 큐 송수신 연동)

### Step 3. 관측성 및 모니터링 구축 (Observability)
- [ ] **헬스체크 및 로깅:** (예: Liveness/Readiness Probe, CloudWatch / Fluent Bit 로그 수집)
- [ ] **지표 수집 및 대시보드:** (예: Prometheus 메트릭 엔드포인트 노출, Grafana 대시보드 연동)

### Step 4. 자동화 및 테스트 환경 구성 (CI/CD & Testbed)
- [ ] **테스트 도구 연동:** (예: Locust / k6 부하 시나리오 스크립트 작성, 테스트 파드 구성)
- [ ] **CI/CD 파이프라인:** (예: GitHub Actions 원클릭 배포 / 파괴 파이프라인 구축)

---

## 4. 🧪 검증 및 측정 결과 (V&V - Verification & Validation)

### 🎯 핵심 검증 결론 (Working Increment Verdict)
> **"그래서 무엇을 증명/측정했는가?"**  
> ➡️ **(예: 10,000건의 동시 요청 인입 시 에러율 0% 유지 및 평균 응답시간 45ms 달성 확인 / 인스턴스 강제 종료 후 30초 내 무중단 복구 검증 완료)**

### � 가치 검증 매트릭스 (Validation Matrix)
- **검증 환경:** (예: AWS ap-northeast-2, EKS v1.36, Locust, Terraform v1.14.3)

| 검증 항목 | 검증 방식 및 실행 명령어 | 기대 성공 기준 | 실제 측정 결과 (로그/수치) | 판정 |
| :--- | :--- | :--- | :--- | :---: |
| **인프라 준비도** | `kubectl get nodes` | 워커 노드 2대 Ready | 2대 노드 Ready (v1.36.0-eks) | ✅ Pass |
| **서비스 간 연결성** | `curl -s -o /dev/null -w "%{http_code}" <URL>` | HTTP 200 응답 | **HTTP 200 OK** | ✅ Pass |
| **지표/모니터링 확인** | `kubectl logs -n <ns> <pod>` 또는 대시보드 쿼리 | 메트릭 수집 및 정상 출력 | 지표 유실 없이 시계열 데이터 적재 | ✅ Pass |
| **부하/장애 테스트** | `locust --headless -u 100 -r 10 --run-time 5m` | 에러율 0.1% 미만, P95 < 200ms | **에러율 0%, P95 110ms 달성** | ✅ Pass |
| **비용 방어/자동화** | GitHub Actions 수동 실행 | 자원 완전 정리 (`0 resource`) | 12분 내 파괴 완료 및 과금 \$0 확인 | ✅ Pass |

### 📦 산출물 링크 및 증빙
- **PR 및 커밋:**
  - [PR #X: 제목](https://github.com/kim001hs/msa-demo/pull/X) (Issue #X 연결)
- **핵심 소스/설정 파일:**
  - `terraform/envs/dev/...`
  - `helm-chart/...`
- **테스트 증빙 자료:** (대시보드 캡처, 테스트 리포트, 로그 발췌 등)

---

## 5. 🚧 트러블슈팅 및 삽질 기록 (Troubleshooting Log)

> 2주 사이클 동안 마주쳤던 가장 치명적이거나 값진 기술적 문제 1~2개를 선정하여 원인과 해결 과정을 기록합니다.

### 🛑 Issue: [문제 제목 (예: GitHub Actions OIDC 인증 시 AssumeRoleWithWebIdentity 거부)]
- **증상 및 에러 로그:**
  ```text
  An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation: Not authorized to perform sts:AssumeRoleWithWebIdentity
  ```
- **원인 분석:** (단순 추측이 아닌 CloudTrail, 로그, 디버깅을 통해 확인한 근본 원인)
- **해결 조치:** (문제를 해결하기 위해 수정한 코드, 설정, 아키텍처적 조치)
- **얻은 인사이트:** (앞으로 유사 문제를 방지하기 위해 정립한 원칙이나 팁)

---

## 6. 🔄 회고 및 다음 사이클 이관 (Retrospective & Technical Debt)

### 🟢 Keep (성공 요인 / 계속 유지할 엔지니어링 프랙티스)
- 이번 주기에 효과적이었던 아키텍처 접근법, 자동화 툴링, 디버깅 기법

### 🔴 Problem (지연 요인 / 병목 및 아쉬웠던 점)
- 작업 진행 중 예상보다 시간을 많이 소모했거나 설계상 아쉬웠던 부분

### 🟡 Technical Debt & Next Cycle (다음 2주 주기로 이관할 과제)
- 이번 사이클의 Working Increment 완성을 위해 의도적으로 생략했거나 타협한 기술 부채
- 다음 Cycle에서 수직 관통으로 다룰 백로그 연결
  1. **과제 1:** (예: IAM 권한 Least Privilege 축소 작업)
  2. **과제 2:** (예: Ingress ALB 전환 및 분산 추적(Jaeger) 붙이기)

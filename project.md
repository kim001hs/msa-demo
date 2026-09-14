# Kubernetes AIOps RCA & Chaos Evaluation Platform

## 1. 프로젝트 개요

Kubernetes 기반 마이크로서비스 환경에서 발생하는 다수의 Alert를
Incident 단위로 정리하고, Metrics / Logs / Traces / Kubernetes Event를
Read-only Agent가 스스로 조사하여 1차 Root Cause Analysis를 수행하는 시스템.

Chaos Engineering을 통해 실제 장애 원인을 알고 있는 환경을 구성하고,
Agent의 RCA 결과와 Ground Truth를 비교하여 정확도와 진단 시간을 정량 평가한다.

---

## 2. 문제 정의

마이크로서비스 환경에서는 하나의 장애가 여러 서비스로 전파되면서
다수의 연쇄 Alert가 발생할 수 있다.

기존 임계치 기반 모니터링은 이상 현상을 탐지할 수 있지만,

- 여러 Alert가 동일 장애에서 발생했는지
- 실제 Root Cause가 무엇인지
- 어떤 서비스까지 영향을 받았는지
- 어떤 대응이 필요한지

를 직접 제공하지 못한다.

또한 LLM을 운영 환경과 연결하더라도
단순히 로그와 Metric을 Prompt에 넣어 요약시키는 방식으로는
실제 운영 Agent의 효용을 검증하기 어렵다.

---

## 3. 핵심 목표

1. Keep을 이용해 다수의 Alert를 Incident 단위로 정리
2. LLM Agent가 Read-only Tool을 사용해 장애를 자율 조사
3. Metrics / Logs / Traces / Kubernetes Event를 Evidence로 활용
4. 구조화된 RCA Report 생성
5. Chaos Engineering으로 장애 Ground Truth 생성
6. RCA Accuracy / Diagnosis Time / Tool Usage 등을 반복 측정
7. 운영 Context가 RCA 품질에 미치는 영향 분석

---

## 4. 전체 아키텍처

Kubernetes MSA
    ↓
Prometheus / Loki / Tempo / Kubernetes Events
    ↓
Keep
    ↓
Incident
    ↓
RCA Orchestrator
    ↓
Fixed Read Adapters
    ↓
LLM Agent
    ↓
Structured RCA Report
    ↓
Evaluator
    ↕
Chaos Ground Truth

선택적 확장:

Remediation Proposal
    ↓
Human Approval
    ↓
GitHub PR
    ↓
ArgoCD
    ↓
Kubernetes
    ↓
Verification

자세한 내용: docs/architecture.md

---

## 5. 주요 구성 요소

### Observability

- Prometheus: Metrics
- Loki: Logs
- Tempo: Distributed Traces
- Kubernetes Events
- Grafana: Visualization

자세한 내용: docs/observability.md

### Incident Management

- Keep
- Alert ingestion
- Deduplication
- Correlation
- Incident generation

Keep은 Observability와 자체 RCA Pipeline 사이의 Incident Layer로 사용한다.

### RCA Agent

- Agentic investigation
- Fixed Read Adapter
- Evidence collection
- Structured RCA
- Runbook / Past Incident Context 실험

자세한 내용: docs/rca-agent.md

### Chaos / Evaluation

- Chaos Mesh
- Ground Truth 기록
- 반복 장애 실험
- RCA Accuracy
- Diagnosis Time
- Tool Calls
- Token Usage

자세한 내용: docs/experiments.md

---

## 6. 구현 단계

### Phase 0 - Baseline

- Online Boutique 배포
- 정상 트래픽 생성
- 서비스 정상 상태 정의

### Phase 1 - Observability + Incident

- Prometheus
- Loki
- Grafana
- Keep
- 기본 Alert / Incident Pipeline
- Pod Kill / CPU Chaos

### Phase 2 - Agentic RCA

- Tempo 추가
- Fixed Read Adapter 구현
- RCA Orchestrator 구현
- Structured RCA Report
- Agent Tool Call 기록

### Phase 3 - Evaluation

- Chaos Scenario 확대
- Ground Truth 자동 저장
- 반복 실험 자동화
- RCA Accuracy / Diagnosis Time 측정
- Context 구성별 성능 비교

### Phase 4 - Optional Remediation

핵심 실험이 완료된 이후 진행한다.

- Remediation Proposal
- Human Approval
- GitHub PR
- ArgoCD
- Post-change Verification

---

## 7. 핵심 실험

### Experiment A - Observability Context

Metrics
vs Metrics + Logs
vs Metrics + Logs + Traces

### Experiment B - Operational Knowledge

Telemetry only
vs Telemetry + Runbook
vs Telemetry + Runbook + Past Incidents

### Experiment C - Alert Correlation

Raw Alerts
vs Keep-correlated Incident

비교 지표:

- RCA Accuracy
- Diagnosis Time
- Tool Calls
- Token Usage
- False Attribution

---

## 8. 평가 지표

- Root Cause Accuracy
- Top-1 / Top-k Accuracy
- False Attribution
- Time to Diagnosis
- Time to Actionable Recommendation
- Tool Call Count
- Token Usage
- Cost
- Recovery Time (Remediation 구현 시)

---

## 9. 현재 상태

### 완료
- ...

### 진행 중
- ...

### 예정
- ...

실제 진행 상황에 맞춰 지속적으로 갱신한다.

---

## 10. 기술 스택

- Kubernetes
- Online Boutique
- Prometheus
- Grafana
- Loki
- Tempo
- Keep
- Chaos Mesh
- ArgoCD
- LLM API
- Python / Go 등

---

## 11. 프로젝트 범위에서 제외

- 자체 Alert Manager 구현
- 자체 Observability Backend 구현
- 범용 Kubernetes Agent 개발
- unrestricted shell Agent
- 완전 자율 Self-Healing
- 자체 Dashboard 개발

---

## 12. 문서

- [Architecture](docs/infra-project//architecture.md)
- [RCA Agent](docs/infra-project//rca-agent.md)
- [Experiments](docs/infra-project//experiments.md)
- [Observability](docs/infra-project//observability.md)
- [Remediation](docs/infra-project//remediation.md)
- [Architecture Decisions](docs/infra-project//decisions.md)
# 🚀 Kubernetes Autonomous Incident Investigation & Quantitative Evaluation Platform

> **프로젝트 명칭:** 쿠버네티스 자율 인시던트 진단(Agentic RCA) 및 카오스 정량 평가 플랫폼  
> **핵심 키워드:** Kubernetes, Observability, Agentic RCA, Chaos Engineering, Quantitative Evaluation, SRE / AIOps

---

## 1. 🎯 프로젝트 개요 (Executive Summary)

본 프로젝트는 마이크로서비스(Kubernetes) 환경에서 복합 장애가 발생했을 때, **Agentic ReAct 루프 기반의 AI 에이전트가 텔레메트리(Metrics, Logs, Traces, Events)와 인프라 배포 이력을 자율적으로 조사하여 근본 원인(RCA)을 규명하는 시스템**을 구축한다.

단순한 모니터링이나 정적 알람 텍스트 요약에 그치지 않고, **카오스 엔지니어링 기반의 재현 가능한 자동 평가 프레임워크(Evaluation Framework)**를 자체 개발하여 에이전트의 진단 정확도(Accuracy), 진단 소요 시간(Time to Diagnosis), 토큰 비용(Cost), 그리고 **도구 호출 효율성(Tool Call Efficiency)**을 반복 정량 측정한다.

조사 엔진의 기저 프레임워크로는 클라우드 네이티브 표준(CNCF Sandbox)인 경량 ReAct 프레임워크(`HolmesGPT` 등)를 채택하며, 여기에 **GitHub 배포 이력 도구(Custom Toolsets), 마이크로서비스 도메인 런북(Runbooks), 과거 장애 포스트모템(RAG)**을 직접 엔지니어링하여 결합함으로써 실전 운영 환경에서 신뢰할 수 있는 AIOps 체계를 완성한다.

### 📌 핵심 목표 (Core Objectives)

1. **자율 인시던트 인입:** Alertmanager Webhook을 통해 실시간 경보를 HolmesGPT 조사 루프로 자동 트리거
2. **ReAct 기반 자율 조사:** LLM Agent가 Read-only Tool을 자율적으로 활용해 가설 수립-검증 사이클 수행
3. **멀티모달 텔레메트리 연동:** Metrics, Logs, Traces, K8s Event, 배포 이력(Git)을 종합 증거(Evidence)로 분석
4. **구조화된 RCA 리포트:** 근본 원인(Root Cause), 영향 범위(Blast Radius), 조치 권고안(Actionable Recommendation) 자동 생성
5. **정량적 벤치마크 검증:** Chaos Engineering 기반 Ground Truth와 비교하여 진단 정확도, 소요 시간, 비용, 도구 효율성을 객관적으로 측정
6. **운영 컨텍스트 영향 분석:** 도메인 런북 및 Git 배포 이력 주입 유무가 RCA 품질과 진단 시간에 미치는 영향 실증

---

## 2. 💡 문제 정의 및 해결 접근법 (Problem Definition & Approach)

### 기존 접근법의 한계
1. **임계치 기반 모니터링의 한계:** 수많은 연쇄 알람(Alert Storm)이 발생했을 때, 최초의 발화 지점과 실제 근본 원인이 무엇인지 엔지니어가 직접 여러 대시보드를 오가며 수동 분석해야 함.
2. **단순 프롬프트 요약형 LLM의 한계:** Alertmanager가 보낸 정적 텍스트만 프롬프트에 넣어 요약하는 방식은 최신 로그나 메트릭을 능동적으로 확인할 수 없어 환각(Hallucination)이 발생하기 쉬움.
3. **무거운 상용/블랙박스 툴의 한계:** 일부 인시던트 관리 도구는 과도하게 많은 리소스(DB, 캐시, 소켓 서버 등)를 요구하며 내부 로직이 닫혀 있어 커스텀 튜닝 및 확장이 제한됨.

### 본 프로젝트의 해결 접근법
1. **Agentic ReAct Loop 채택:** 가설 수립 ➡️ 도구 호출(Query/Logs/Events) ➡️ 결과 관찰 ➡️ 가설 검증의 능동적 조사 사이클 구현.
2. **운영 컨텍스트 통합:** 단순 텔레메트리뿐 아니라 장애 직전의 **코드 커밋, PR 머지, 환경변수 변경 이력**을 조사 도구로 에이전트에게 제공.
3. **정량적 실증 평가:** "잘 작동하는 것 같다"는 주관적 평가를 배제하고, 카오스 주입을 통한 Ground Truth(정답) 기반의 객관적 벤치마크 수행.

---

## 3. 🏗️ 전체 시스템 아키텍처 (System Architecture)

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Workload Layer                       │
│  - Online Boutique (11 Microservices) + Locust Load Generator          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Telemetry Streaming
┌───────────────────────────────────▼────────────────────────────────────┐
│                       Observability & Alerts Layer                     │
│  - Metrics: Prometheus / Alertmanager                                  │
│  - Logs: Loki / Promtail                                               │
│  - Traces: Tempo / OpenTelemetry (확장 예정)                            │
│  - Events: Kube-State-Metrics / K8s Events                             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Webhook / Alert Event
┌───────────────────────────────────▼────────────────────────────────────┐
│                  Autonomous Investigation Engine                       │
│  [ Agentic ReAct Loop: Plan → Act → Observe → Diagnose ]               │
│                                                                        │
│   Built-in Adapters       Custom Toolsets (자체 개발) Operational Rules │
│   ├─ kubectl (logs/desc)  ├─ GitHub (Commit/PR/Merge) ├─ Domain Runbook│
│   ├─ PromQL Queries       ├─ ArgoCD Rollout History   └─ Post-mortem   │
│   └─ K8s Event Analyzer   └─ Custom Health APIs          Knowledge RAG │
└───────────────────┬─────────────────────────────────┬──────────────────┘
                    │ Structured RCA Report           │ Remediation Proposal
┌───────────────────▼────────────────────────┐ ┌──────▼───────────────────┐
│       Automated Evaluation Framework       │ │    Remediation Pipeline │
│  (AIOps Benchmark & Evaluation Engine)     │ │                         │
│  - Ground Truth vs RCA Report 자동 채점    │ │  - Safe Remediations    │
│  - Top-1/Top-k Root Cause Accuracy         │ │  - Human-in-the-Loop    │
│  - Tool Call Efficiency & Token Cost       │ │    Approval (Slack/CLI) │
│  - Repeated Benchmark Execution Runner     │ │  - Rollback / Helm Sync │
└───────────────────▲────────────────────────┘ └─────────────────────────┘
                    │ Fault Injection & Clean State Reset
┌───────────────────┴────────────────────────────────────────────────────┐
│                     Chaos Engineering Platform                         │
│  - Chaos Mesh (Pod Kill, Network Delay, CPU/Memory Stress, Packet Drop) │
└────────────────────────────────────────────────────────────────────────┘
```

### 선택적 복구 확장 흐름 (Optional Remediation Workflow)
```text
Remediation Proposal (조치 제안)
        ↓
Human-in-the-Loop Approval (인간 승인 - Slack / CLI)
        ↓
GitHub PR 생성 또는 ArgoCD Rollback
        ↓
Kubernetes 클러스터 동기화
        ↓
Verification (정상 상태 복구 검증)
```

자세한 아키텍처 상세: [docs/architecture.md](docs/architecture.md)

---

## 4. 🛠️ 자체 엔지니어링 및 커스텀 확장 영역 (Custom Engineering)

조사 엔진(기저 프레임워크: `HolmesGPT` 등)의 유연한 플러그인 구조를 활용하여, 아래의 **커스텀 모듈을 엔지니어가 직접 설계하고 개발**한다:

### 1) 배포 및 형상 관리 도구 확장 (Custom Toolsets & MCP)
* **GitHub 배포/변경 이력 도구:**
  - 장애 발생 직전 머지된 PR, 최근 커밋 메시지, 수정된 매니페스트/환경변수 변경 내역을 에이전트가 직접 조회하는 도구 개발.
  - 에이전트가 "최근 배포된 PR의 Redis 타임아웃 오기입"을 인과관계로 연결하도록 지원.
* **GitOps / ArgoCD 동기화 상태 추적 도구:**
  - 배포 상태, OutOfSync 내역, 롤아웃 실패 로그를 수집하는 도구 추가.
* **Model Context Protocol (MCP) 표준 규격 연동:**
  - 사내 자체 진단 스크립트 및 인프라 API를 표준 MCP 서버로 패키징하여 에이전트에 플러그인 연결.

### 2) 도메인 특화 런북 및 지식(Runbooks & RAG)
* **마이크로서비스 의존성 런북 주입:**
  - Online Boutique 각 서비스의 통신 경로(예: `frontend ➡️ checkoutservice ➡️ paymentservice`)를 담은 런북 코딩.
  - 에이전트가 의존성 그래프에 따라 체계적으로 상위/하위 컴포넌트를 탐색하도록 가이드라인 제공.
* **과거 장애 포스트모템(Post-mortem) 지식 베이스:**
  - 과거 장애 이력과 조치 내역을 적재하여, 유사 증상 감지 시 과거 해결책을 참고하도록 유도.

### 3) 실행 정책 및 안전 가드레일 (Safe Guardrails)
* 파괴적인 명령어(`delete namespace`, 무단 데이터 삭제 등)를 사전에 차단하는 안전 정책 필터 적용.

자세한 에이전트 명세: [docs/rca-agent.md](docs/rca-agent.md)

---

## 5. 🧪 재현 가능한 자동 평가 프레임워크 (Evaluation & Benchmark)

오픈소스 AIOps 벤치마크 방법론을 바탕으로, 인시던트 분석 에이전트의 실질적 성능을 정량적으로 증명하는 **재현 가능한 평가 파이프라인**을 구축한다.

### 자동 평가 사이클 (Continuous Evaluation Loop)
```text
[1. 클러스터 초기화] ➡️ [2. 카오스 장애 주입] ➡️ [3. 경보 발생] ➡️ 
[4. 에이전트 RCA 자율 실행] ➡️ [5. Ground Truth 자동 채점] ➡️ 
[6. 메트릭/비용 기록] ➡️ [7. 클러스터 원상 복구] ➡️ [8. N회 반복 실험]
```

### 핵심 측정 메트릭 (Key Metrics)
1. **RCA 정확도 (Root Cause Accuracy):**
   - **Top-1 / Top-k 원인 일치율:** 실제 주입된 장애(Ground Truth)와 에이전트가 지목한 1차 원인의 일치 여부
   - **연쇄 영향 범위 식별율 (Blast Radius Accuracy):** 전파된 피해 서비스 목록을 정확히 도출했는지 검증
2. **진단 시간 (Time to Diagnosis):**
   - 경보 인입 시점부터 실행 가능한 조치 권고안(Actionable Recommendation) 도출까지의 소요 시간
3. **도구 호출 효율성 (Tool Call Efficiency):**
   - **불필요한 중복 도구 호출(Redundant Tool Calls)** 비율 측정 (동일 로그/메트릭을 반복 재조회하는 비효율 탐지)
4. **경제성 및 토큰 비용 (Token & Financial Cost):**
   - 진단 1건당 소모된 입/출력 토큰 수 및 실제 API 비용($) 산출

자세한 실험 설계: [docs/experiments.md](docs/experiments.md)

---

## 6. 🔬 핵심 A/B 비교 실험 설계 (Core Experiments)

구축된 평가 플랫폼을 통해 다음 3가지 핵심 연구 가설을 정량 검증한다:

### [실험 A] 관측 데이터 계층(Layer)과 진단 정확도의 상관관계
* **비교군:** Metrics 단독 vs Metrics + Logs vs Metrics + Logs + Traces
* *가설 검증:* 분산 트레이싱(Trace) 데이터의 유무가 연쇄 장애의 최초 원인 지점을 식별하는 정확도에 미치는 영향 분석.

### [실험 B] 운영 컨텍스트(런북 및 배포 이력) 주입 효과
* **비교군:** 텔레메트리 단독 vs 텔레메트리 + 런북 vs 텔레메트리 + 런북 + GitHub 배포 이력
* *가설 검증:* 코드 변경으로 인한 장애 상황에서 배포 이력 도구가 진단 시간(TTD)을 얼마나 단축시키는지 증명.

### [실험 C] 도구 호출 최적화와 비용 효율성
* **비교군:** 기본 자유 탐색 루프 vs 단계별 순차 탐색 정책(Metrics ➡️ Events ➡️ Logs) 및 중복 방지 필터
* *가설 검증:* 진단 정확도를 유지하면서 도구 호출 수와 토큰 비용을 30% 이상 절감 가능한 최적화 정책 도출.

---

## 7. 💻 기술 스택 및 컴포넌트 구성 (Technology Stack)

| 구분 | 도입 오픈소스 및 기술 | 역할 및 목적 |
| :--- | :--- | :--- |
| **Workload** | Kubernetes (EKS v1.36), Online Boutique, Locust | 11개 마이크로서비스 워크로드 및 실제 부하 생성 |
| **Observability** | Prometheus, Alertmanager, Grafana, Loki, Tempo | 메트릭, 로그, 트레이스, 이벤트 풀스택 수집 및 시각화 ([docs/observability.md](docs/observability.md)) |
| **Investigation Engine** | **CNCF HolmesGPT Framework**, Python, FastMCP | ReAct 자율 조사 루프 실행 및 커스텀 툴셋 통합 기반 ([docs/rca-agent.md](docs/rca-agent.md)) |
| **Chaos & Testing** | Chaos Mesh, Python Automated Runner | 파드 킬, 네트워크 지연, 리소스 고갈 등 재현 가능한 장애 주입 ([docs/experiments.md](docs/experiments.md)) |
| **DevOps / CI/CD** | Terraform, GitHub Actions, Helm, ArgoCD | 클러스터 FinOps 프로비저닝 및 GitOps 배포 관리 ([docs/decisions.md](docs/decisions.md)) |

---

## 8. 📅 단계별 구현 로드맵 (Phased Roadmap)

| 단계 | 주요 작업 목표 | 상태 |
| :--- | :--- | :---: |
| **Phase 0: Baseline** | • EKS v1.36 인프라 프로비저닝 & Online Boutique 가동<br>• FinOps 원클릭 배포/삭제 자동화 워크플로우 완성 | **완료 (Cycle 0)** |
| **Phase 1: Agentic RCA MVP** | • `kube-prometheus-stack` 메트릭 수집 완료<br>• 조사 엔진 프레임워크 연동 (EKS 클러스터 접근 권한 부여)<br>• Alertmanager Webhook ➡️ AI 자율 조사 E2E 1회 관통 | **진행 예정** |
| **Phase 2: Chaos & Eval 자동화** | • Chaos Mesh 배포 (Pod Kill, Network Latency 등 시나리오 구성)<br>• 재현 가능한 평가 스크립트 개발 (정답지 매칭 및 자동 채점)<br>• 정확도 / 시간 / 토큰 / 도구 효율성 자동 수집 파이프라인 | 예정 |
| **Phase 3: Custom 확장 & 벤치마크** | • GitHub Commit/PR 조회 커스텀 툴셋 구현 및 엔진 결합<br>• 마이크로서비스 도메인 런북 주입 및 A/B 테스트 수행<br>• 다차원 정량 비교 분석 리포트 도출 | 예정 |
| **Phase 4: 최적화 & 종합 완성** | • 도구 호출 효율성 최적화 및 안전 가드레일 정책 완성<br>• 아키텍처 문서화 및 종합 분석 결과서 완성 | 예정 |

---

## 9. 🚫 프로젝트 범위에서 제외하는 사항 (Out of Scope)

* **자체 LLM 모델 학습:** Foundation Model 자체를 사전학습(Pre-training)하지 않으며, API(OpenAI/Claude)를 활용한 에이전틱 시스템 엔지니어링에 집중한다.
* **비승인 완전 자동 조치:** 인간의 승인 없는 파괴적 자동 복구는 배제하며, 항상 안전한 권고안 제시 및 승인형(Human-in-the-Loop) 제어로 설계한다.
* **불필요한 무거운 인프라:** 불필요한 별도 풀스택 대시보드 개발을 지양하고, Grafana와 자동 리포트를 활용하여 FinOps $0 원칙을 수호한다.

---

## 10. 📑 관련 문서 링크 (Documentation Links)

* [시스템 아키텍처 정의서 (Architecture)](docs/architecture.md)
* [아키텍처 결정 기록서 (ADR-001: x86_64 선정 배경)](docs/decisions.md)
* [RCA Agent 상세 명세서 (RCA Agent)](docs/rca-agent.md)
* [옵저버빌리티 구축 명세서 (Observability)](docs/observability.md)
* [실험 및 벤치마크 설계서 (Experiments)](docs/experiments.md)
* [복구 파이프라인 명세서 (Remediation)](docs/remediation.md)
* [작업 로그 (Work Logs)](docs/work-logs/)
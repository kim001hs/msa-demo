# Experiment Design

## Research Questions & Core Experiments

### [실험 A] 관측 데이터 계층(Layer)과 진단 정확도의 상관관계
- **비교군:** Metrics 단독 vs Metrics + Logs vs Metrics + Logs + Traces
- **연구 질문:** 분산 트레이싱(Trace) 데이터의 유무가 연쇄 장애의 최초 원인 지점을 식별하는 정확도(Top-1/Top-k)에 미치는 영향은 무엇인가?

### [실험 B] 운영 컨텍스트(런북 및 배포 이력) 주입 효과
- **비교군:** 텔레메트리 단독 vs 텔레메트리 + 런북 vs 텔레메트리 + 런북 + GitHub 배포 이력
- **연구 질문:** 코드/설정 변경으로 인한 장애 상황에서 배포 이력 조회 도구가 진단 시간(TTD)과 정확도를 얼마나 향상시키는가?

### [실험 C] 도구 호출 최적화와 비용 효율성
- **비교군:** 기본 자유 탐색 루프 vs 단계별 순차 탐색 정책(Metrics ➡️ Events ➡️ Logs) 및 중복 방지 필터
- **연구 질문:** 진단 정확도를 유지하면서 불필요한 도구 호출(Redundant Tool Calls)과 토큰 비용을 얼마나 절감할 수 있는가?

## Fault Scenarios

### F01 Pod Kill
Ground Truth:
...

### F02 CPU Saturation
...

### F03 OOM
...

### F04 Network Latency
...

### F05 Redis Failure
...

## Metrics

## Repetition

각 scenario N회 실행

## Evaluation Method

## Results

실험 완료 후 실제 결과 기록
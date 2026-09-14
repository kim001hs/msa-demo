# Architecture Decision Records (ADR)

본 문서는 인프라, 아키텍처 및 기술 스택 선정 과정에서 내린 주요 의사결정의 배경과 근거(Rationale)를 기록합니다.

---

## ADR-001: EKS 워커 노드 아키텍처 선정 (ARM64 대신 x86_64 t3.large 채택)

* **날짜:** 2026-09-14
* **상태:** 확정 (Accepted)
* **결정자:** 플랫폼 / 인프라 엔지니어

### 1. 배경 (Context)
초기 아키텍처 설계 단계에서는 AWS Graviton(`t4g.large`)을 도입하여 x86_64 인스턴스 대비 약 20%의 컴퓨팅 비용 절감(FinOps)을 목표로 설정했습니다.

일반적인 마이크로서비스(Online Boutique) 및 관측 스택(Prometheus, Grafana Loki, Tempo, Keep)은 공식 멀티아키텍처(Multi-arch) 컨테이너 이미지를 지원하므로 ARM64 환경에서도 정상 구동이 가능합니다. 

그러나 본 프로젝트의 핵심 목표 중 하나인 **Chaos Engineering(장애 자동 주입 및 정량 평가 파이프라인)**을 구현하기 위해 **Chaos Mesh**를 도입하는 과정에서 심각한 아키텍처 종속성 및 런타임 호환성 문제가 검토되었습니다.

### 2. 결정 (Decision)
EKS 워커 노드 인스턴스 및 AMI 아키텍처를 ARM64(`t4g.large`, AL2023_ARM_64_STANDARD)에서 **x86_64(`t3.large`, AL2023_x86_64_STANDARD)**로 전환하여 표준화합니다.

*(참고: 쿠버네티스 클러스터 외부에 위치한 경량 NAT 인스턴스인 `fck-nat`는 장애 주입 도구의 영향을 받지 않는 순수 패킷 포워딩 장비이므로, 비용 최적화를 위해 초경량 `t4g.nano` ARM64 인스턴스를 유지합니다.)*

### 3. 기술적 근거 (Rationale)

#### ① Chaos Mesh의 심층 아키텍처 종속성
Chaos Mesh는 단순한 컨테이너 기반 웹 애플리케이션이 아니라, 노드의 커널 레벨에서 시스템 콜과 트래픽을 가로채는 인프라 도구입니다:
- **eBPF 및 어셈블리 주입 차이:** eBPF 바이트코드 컴파일 타임의 레지스터 구조체(`pt_regs`), 어셈블리 주입(`ptrace`), 커널 헤더 심볼이 x86_64와 aarch64(arm64) 간에 완전히 다릅니다.
- **커널 모듈 부재 (EKS AL2023 ARM64):** Chaos Mesh의 `NetworkChaos`(`tc / netem` 기반 패킷 지연/유실) 실행 시, Amazon Linux 2023 ARM64 기본 커널에는 `sch_netem` 모듈이 누락되어 있어 `RTNETLINK answers: No such file or directory` 에러와 함께 네트워크 장애 주입이 실패합니다.
- **실험적 arm64 지원의 신뢰성 문제:** Chaos Mesh의 `chaos-daemon`은 x86_64 기반으로 하드코딩된 시스템 콜 오프셋과 eBPF 코드가 많아, arm64 노드에서는 JVM Chaos, Time Chaos, 특정 eBPF 기반 IO 장애 주입 시 주입 실패 또는 노드 커널 패닉을 유발할 위험이 높습니다.

#### ② 엔지니어링 리소스 및 프로젝트 목표 정렬
- 본 프로젝트의 본질적 가치는 **"장애 시나리오 주입 $\rightarrow$ 다차원 텔레메트리 관측 $\rightarrow$ Read-only RCA Agent 자율 조사 및 정량 평가"** 파이프라인을 완성하는 것입니다.
- 실습 시간 위주로 가동할 경우 `t4g.large`와 `t3.large`의 실제 월 비용 차이는 수천 원 안팎에 불과합니다.
- 미미한 비용을 절감하려다 Chaos Mesh의 커널 모듈 크로스 컴파일 및 아키텍처 디버깅에 수십 시간을 낭비하는 것은 명백한 주객전도(YAGNI/오버엔지니어링)입니다.
- 따라서 **100% 신뢰성 있는 장애 재현성을 보장하는 x86_64 환경을 채택**하는 것이 가장 합리적인 결정입니다.

### 4. 결과 및 영향 (Consequences)

* **긍정적 영향:**
  - Chaos Mesh의 커널/네트워크/IO 레벨 장애 주입이 예외 없이 완벽하게 동작합니다.
  - 마이크로서비스 및 서드파티 모니터링 에이전트 배포 시 `exec format error` 등의 아키텍처 불일치 위험이 0%로 제거됩니다.
  - 개발/실험 환경의 재현성과 신뢰도가 극대화됩니다.
* **비용 관리 대책:**
  - x86_64 전환에 따른 단가 차이는 **"실습 후 노드 스케일 인(`desired_size=0`) 또는 `terraform destroy`"**를 기본 워크플로우로 삼아 실청구 비용을 철저히 방어합니다.

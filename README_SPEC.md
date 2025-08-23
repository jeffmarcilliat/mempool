# Spatial Mempool — VisionOS 2 (Fork of mempool.space)

**Mission**  
Build a polished, fully-functional **VisionOS 2 app** that reimagines [mempool.space](https://mempool.space) as an interactive 3D experience. Optimize for elegance, design quality, and *wow factor* suitable for a VP review. Work autonomously; present a finished package only after passing each quality gate.

---

## Objectives
- VisionOS 2 (RealityKit + SwiftUI) app visualizing the Bitcoin mempool + recent blocks in 3D.  
- Live data via mempool backend (REST + WebSocket). Public or self-hosted node support.  
- Executive-quality design and documentation (VP-ready deck).  
- Strict AGPL-3.0 compliance.

### Non-Goals (this phase)
- Lightning topology, ordinals, multi-chain, or custom indexers.  
- Advanced analytics beyond fee projections and backlog visuals.

---

## Quality Gates

### 1. Foundations Gate — “Ready to Build”
- Decide: keep/restructure/restart repo; justify in `docs/DECISIONS.md`.  
- VisionOS 2 skeleton compiles on CI (Xcode 16).  
- Dockerized mempool backend with config for public vs. self-hosted node; Tor proxy optional.  
- Data adapters: REST bootstrap + WS streaming for blocks/tx/fee data.  
- AGPL-3.0 license + attribution in place.  
- Basic telemetry/logging; feature flags for heavy visuals.  

**Artifacts:** CI badge/screens, `backend/compose.yml`, `docs/ARCHITECTURE.md`.

---

### 2. Interaction Gate — “It Feels Great”
- **Scenes:**  
  - Mempool View: stacked fee strata; live inflow; density conveys backlog.  
  - Blocks View: floating slabs for recent blocks; immersive entry to inspect txs.  
- Gaze/hand interactions reliable and performant.  
- Smooth frame rate; back-pressure handling for WS bursts.  
- Design system (type, color, motion rules) codified; 2–3 explorations compared in `docs/DESIGN_EXPLORATIONS.pdf`.  

**Artifacts:** short demo capture (≤30s), perf notes, `docs/DESIGN_TOKENS.md`.

---

### 3. Completeness Gate — “Fully Functional”
- Features: tx/address search, fee recommendations, error/empty states.  
- Self-host toggle (public vs. private node) with setup docs, including Tor option.  
- Unit tests for parsers/formatters; UI snapshot tests; resiliency tests.  
- Fresh setup <30 minutes (excluding Xcode install).  

**Artifacts:** `docs/OPERATIONS.md`, test coverage summary, updated captures.

---

### 4. Polish Gate — “VP-Ready”
- VP deck: `docs/DESIGN_REVIEW.pdf` with narrative, rationale, screens, motion refs.  
- Signed archive/TestFlight-ready `.ipa` (or unsigned archive + signing steps).  
- First-run UX, hints/tooltips, iconography, accessibility basics.  
- PRs squash-merged, conventional commits, CI green, screenshots in PRs.  

**Artifacts:** final deck, release notes, demo capture (≤60s).

---

## Deliverables
- PRs into `main`, CI green.  
- `/app-visionos` Xcode project; `/backend` Dockerized mempool; `/docs` filled out.  
- Docs required:  
  - `ARCHITECTURE.md` — data flow, scene graph, threading, error handling.  
  - `DECISIONS.md` — repo/restart, rendering choices, perf tradeoffs.  
  - `DESIGN_TOKENS.md` — type scale, color, motion rules.  
  - `OPERATIONS.md` — run against public/self-host node; Tor config.  
  - `DESIGN_REVIEW.pdf` — VP-ready deck.  
  - `ISSUE_LOG.md` + `WEEKLY_REPORT.md`.

---

## Working Rules
- Full autonomy: restructure or restart for best results.  
- No interim code dumps; only present when a gate is passed.  
- If a gate isn’t passed, iterate until it is — don’t advance early.  
- Keep `ISSUE_LOG.md` and `WEEKLY_REPORT.md` up to date.  

---

## Definition of Done
- All four gates passed.  
- Repo contains PRs, docs, build artifacts, and VP deck.  
- App connects to mempool, renders immersive 3D UX, and feels “senior-level polished.”  
- AGPL-3.0 license compliance maintained.

---

## Repo & CI Structure

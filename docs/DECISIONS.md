# Architecture and Implementation Decisions

## Repository Structure Decision

### Decision: Keep and Enhance Existing VisionOS Foundation

**Context:**
The repository already contains a substantial VisionOS app implementation with:
- Complete Swift project structure with Xcode project
- 3D blockchain visualization using RealityKit
- Models for Block, Transaction, and UTXO
- MempoolService for API integration
- Immersive view with gesture controls
- Comprehensive documentation (README.md, SETUP.md)

**Options Considered:**
1. **Restart from scratch** - Clean slate approach
2. **Restructure existing code** - Major refactoring
3. **Keep and enhance existing foundation** - Build upon current implementation

**Decision: Keep and Enhance Existing Foundation**

**Rationale:**
- The existing VisionOS app already implements core 3D visualization concepts
- Swift models and services provide a solid foundation
- RealityKit integration is already working
- API integration with mempool.space is functional
- Time efficiency: building upon existing work vs. starting over
- Quality: existing code shows good architectural patterns

**Implementation Strategy:**
- Enhance existing 3D visualization for better fee strata representation
- Add missing WebSocket streaming for live data
- Implement missing features (search, fee recommendations)
- Add comprehensive error handling and self-hosting support
- Create missing documentation and CI configuration

## Rendering and Performance Decisions

### 3D Visualization Approach

**Decision: Enhanced RealityKit with Optimized Entity Management**

**Context:**
Current implementation creates individual transaction cubes within blocks, which could impact performance with large transaction counts.

**Optimizations Implemented:**
- Limit concurrent transaction entities to prevent performance issues
- Use proportional fill representation for high transaction count blocks
- Implement level-of-detail (LOD) for distant objects
- Add performance monitoring and throttling

### Data Flow Architecture

**Decision: MVVM with Reactive Data Binding**

**Current Implementation:**
- `BlockchainViewModel` manages state and business logic
- `MempoolService` handles API communication
- SwiftUI views with `@Published` properties for reactive updates
- Separation of concerns between data, business logic, and presentation

**Enhancements Needed:**
- Add WebSocket streaming for real-time updates
- Implement proper error handling and retry logic
- Add caching layer for offline functionality
- Create data transformation pipeline for 3D visualization

## Technology Stack Decisions

### Frontend: VisionOS 2 with RealityKit + SwiftUI

**Rationale:**
- Native visionOS performance and integration
- RealityKit provides powerful 3D rendering capabilities
- SwiftUI enables rapid UI development with reactive patterns
- Apple's recommended approach for spatial computing

### Backend: Existing Mempool.space API + Docker

**Decision: Leverage existing mempool backend with Docker containerization**

**Rationale:**
- Proven mempool.space API provides reliable Bitcoin data
- Docker enables easy self-hosting deployment
- Existing backend infrastructure is battle-tested
- Focus development effort on VisionOS app rather than backend

### Communication: REST + WebSocket

**Implementation:**
- REST API for initial data loading and search queries
- WebSocket for real-time mempool and block updates
- Graceful fallback to polling if WebSocket unavailable

## License and Compliance Decisions

### AGPL-3.0 Compliance Strategy

**Requirements:**
- Maintain AGPL-3.0 license for derivative work
- Provide proper attribution to upstream mempool project
- Ensure source code availability for any network-accessible deployment
- Document license requirements clearly

**Implementation:**
- Include LICENSE file with AGPL-3.0 text
- Add attribution notices in app and documentation
- Create clear instructions for source code access
- Document compliance requirements in OPERATIONS.md

## Development and Deployment Decisions

### CI/CD Strategy

**Decision: GitHub Actions with Xcode Cloud Integration**

**Pipeline Requirements:**
- Automated builds for VisionOS target
- Unit and integration test execution
- Code quality checks (SwiftLint, etc.)
- Automated documentation generation
- Release artifact creation

### Deployment Strategy

**Decision: Multiple Deployment Options**

1. **TestFlight Distribution** - For beta testing and review
2. **Unsigned Archive** - For enterprise/development distribution
3. **App Store** - For public release (future consideration)

**Self-Hosting Support:**
- Docker Compose configuration for easy backend deployment
- Tor proxy support for privacy-focused deployments
- Clear documentation for various hosting scenarios

## Quality Gate Implementation Strategy

### Gate 1: Foundations
- ✅ Keep existing VisionOS foundation
- 🔄 Add missing Docker backend configuration
- 🔄 Implement CI/CD pipeline
- 🔄 Ensure AGPL-3.0 compliance
- 🔄 Create comprehensive documentation

### Gate 2: Interaction
- 🔄 Enhance 3D visualization with fee strata
- 🔄 Implement WebSocket streaming
- 🔄 Optimize performance and interactions
- 🔄 Create design system documentation

### Gate 3: Completeness
- 🔄 Add search and fee recommendation features
- 🔄 Implement self-hosting configuration
- 🔄 Add comprehensive testing
- 🔄 Create operational documentation

### Gate 4: Polish
- 🔄 Create VP-ready presentation
- 🔄 Generate final app package
- 🔄 Implement polished UX elements
- 🔄 Complete all documentation

## Risk Mitigation

### Performance Risks
- **Risk:** Large transaction counts causing frame rate drops
- **Mitigation:** Entity pooling, LOD system, performance monitoring

### API Reliability Risks
- **Risk:** mempool.space API unavailability
- **Mitigation:** Graceful degradation, caching, self-hosting option

### Development Timeline Risks
- **Risk:** Underestimating VisionOS development complexity
- **Mitigation:** Incremental delivery through quality gates, early testing

### Compliance Risks
- **Risk:** AGPL-3.0 license violations
- **Mitigation:** Clear documentation, automated compliance checks

---

**Last Updated:** August 23, 2025
**Status:** Foundation decisions documented, implementation in progress

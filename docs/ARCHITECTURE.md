# Spatial Mempool - Architecture Documentation

## Overview

Spatial Mempool is a VisionOS 2 application that provides an immersive 3D visualization of the Bitcoin blockchain and mempool. The application transforms traditional 2D blockchain data into an interactive spatial computing experience.

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VisionOS App                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   SwiftUI Views │  │  RealityKit 3D  │  │ Gesture/Gaze │ │
│  │                 │  │   Rendering     │  │   Controls   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   ViewModels    │  │     Models      │  │   Services   │ │
│  │    (MVVM)       │  │  (Data Layer)   │  │ (API/Network)│ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Network Layer                               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   REST API      │  │   WebSocket     │  │  Tor Proxy   │ │
│  │   (Bootstrap)   │  │  (Real-time)    │  │  (Optional)  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Backend Services                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Mempool.space   │  │  Self-hosted    │  │   Bitcoin    │ │
│  │   (Public)      │  │    Backend      │  │     Node     │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Application Startup
```
App Launch → ViewModel.loadData() → MempoolService.fetchBlocks() → API Request → Data Processing → 3D Entity Creation
```

### 2. Real-time Updates
```
WebSocket Connection → New Block/Transaction → ViewModel Update → 3D Scene Update → Animation/Transition
```

### 3. User Interaction
```
Gaze/Gesture Input → Hit Testing → Entity Selection → Detail View → API Fetch (if needed) → UI Update
```

## Component Architecture

### VisionOS App Layer

#### 1. App Entry Point
- **MempoolVisionOSApp.swift**: Main app structure with immersive space configuration
- **ContentView.swift**: Launch view that automatically opens immersive experience

#### 2. Views (SwiftUI + RealityKit)
- **BlockchainImmersiveView.swift**: Main 3D immersive experience
- **MempoolView.swift**: Mempool-specific visualization
- **BlockchainView.swift**: Traditional blockchain view
- **TransactionView.swift**: Individual transaction details
- **UTXOView.swift**: UTXO exploration interface

#### 3. ViewModels (MVVM Pattern)
- **BlockchainViewModel.swift**: Central state management
  - Manages selected blocks, transactions, UTXOs
  - Coordinates between views and services
  - Handles view state transitions

#### 4. Models (Data Layer)
- **Block.swift**: Bitcoin block representation
- **Transaction.swift**: Transaction data structure
- **UTXO.swift**: Unspent transaction output model

#### 5. Services (Network Layer)
- **MempoolService.swift**: API communication service
  - REST API integration
  - WebSocket streaming (planned)
  - Error handling and retry logic

### 3D Scene Graph

```
RootEntity
├── LightingEntities
│   ├── DirectionalLight (main)
│   ├── AmbientLight (fill)
│   └── FillLight (bottom)
├── BlockEntities
│   ├── Block_0 (latest)
│   │   ├── BlockGeometry (translucent cube)
│   │   ├── TransactionCubes (internal visualization)
│   │   └── BlockInfo (etched text)
│   ├── Block_1
│   └── Block_N
├── MempoolEntities (planned)
│   ├── PendingTransactions
│   └── FeeStrata
└── UIElements
    ├── LoadingText
    └── InteractionHints
```

## Threading Model

### Main Thread (MainActor)
- UI updates and SwiftUI state management
- RealityKit scene updates
- User interaction handling

### Background Threads
- Network requests (URLSession)
- Data processing and transformation
- 3D entity creation (heavy operations)

### Thread Safety
- All ViewModel properties marked with `@Published` for main thread access
- Network operations use `async/await` with proper actor isolation
- RealityKit updates performed on main thread

## Memory Management

### Entity Lifecycle
1. **Creation**: Entities created on-demand when blocks are loaded
2. **Pooling**: Reuse entities for performance optimization
3. **Cleanup**: Remove entities when no longer visible or needed

### Performance Optimizations
- **Level of Detail (LOD)**: Reduce complexity for distant objects
- **Culling**: Hide entities outside view frustum
- **Batching**: Group similar operations for efficiency

## Error Handling

### Network Errors
- Graceful degradation when API unavailable
- Retry logic with exponential backoff
- Fallback to cached data when possible

### Rendering Errors
- Safe entity creation with error boundaries
- Performance monitoring and throttling
- Graceful handling of memory pressure

### User Experience
- Clear error messages in spatial UI
- Recovery suggestions and actions
- Offline mode capabilities

## Security Considerations

### Network Security
- HTTPS for all API communications
- Certificate pinning for production
- Tor proxy support for privacy

### Data Privacy
- No personal data collection
- Local caching with appropriate retention
- Clear data handling policies

## Performance Characteristics

### Target Performance
- **Frame Rate**: 90 FPS minimum for VisionOS
- **Latency**: <100ms for user interactions
- **Memory**: <500MB typical usage
- **Network**: Efficient data usage with compression

### Monitoring
- Frame rate monitoring
- Memory usage tracking
- Network performance metrics
- User interaction analytics

## Scalability

### Data Volume
- Support for 1000+ blocks in memory
- Efficient pagination for historical data
- Streaming updates for real-time data

### User Load
- Optimized for single-user experience
- Potential for multi-user shared spaces (future)

## Integration Points

### External APIs
- **mempool.space API**: Primary data source
- **Bitcoin Core RPC**: Self-hosted node support
- **WebSocket streams**: Real-time updates

### Platform Integration
- **visionOS**: Native spatial computing features
- **ARKit**: World tracking and scene understanding
- **RealityKit**: 3D rendering and physics

## Development Architecture

### Build System
- Xcode project with Swift Package Manager
- Automated builds with GitHub Actions
- Code quality checks and testing

### Testing Strategy
- Unit tests for models and services
- Integration tests for API communication
- UI tests for critical user flows
- Performance tests for 3D rendering

### Documentation
- Inline code documentation
- Architecture decision records
- API documentation
- User guides and setup instructions

## Deployment Architecture

### App Distribution
- TestFlight for beta testing
- App Store for public release
- Enterprise distribution for internal use

### Backend Deployment
- Docker containers for self-hosting
- Kubernetes support for scaling
- Tor hidden service configuration

---

**Version**: 1.0  
**Last Updated**: August 23, 2025  
**Status**: Initial architecture documented

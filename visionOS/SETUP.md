# Mempool VisionOS Setup Guide

This guide will help you set up and run the Mempool VisionOS blockchain explorer on your Apple Vision Pro or in the simulator.

## Prerequisites

### Hardware Requirements
- **Apple Vision Pro** (for full immersive experience)
- **Mac with Apple Silicon** (M1/M2/M3) for development
- **Xcode 15.0+** with visionOS SDK

### Software Requirements
- **macOS 14.0+** (Sonoma)
- **Xcode 15.0+** with visionOS development tools
- **Apple Developer Account** (for device deployment)
- **visionOS 1.0+** runtime

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/mempool/mempool.git
cd mempool/visionOS
```

### 2. Open the Project
```bash
open MempoolVisionOS.xcodeproj
```

### 3. Configure Build Settings

#### Target Configuration
1. Select the **MempoolVisionOS** target
2. Go to **Signing & Capabilities**
3. Set your **Team** and **Bundle Identifier**
4. Ensure **visionOS** is selected as the deployment target

#### API Configuration
1. Open `MempoolService.swift`
2. Update the `baseURL` if you want to use a different mempool.space instance:
   ```swift
   private let baseURL = "https://your-mempool-instance.com/api"
   ```

### 4. Build and Run

#### Simulator Testing
1. Select **Vision Pro Simulator** as your target device
2. Press **Cmd+R** to build and run
3. The app will launch in the simulator

#### Device Testing
1. Connect your **Apple Vision Pro** via USB
2. Select your device from the device list
3. Press **Cmd+R** to build and run
4. The app will install and launch on your device

## Features Overview

### 🏗️ 3D Blockchain Visualization
- **Immersive Chain View**: Walk through the blockchain as connected 3D blocks
- **Real-time Updates**: Live data from mempool.space API
- **Interactive Navigation**: Use hand gestures and eye tracking

### 🔍 Block Exploration
- **Block Inspection**: Tap blocks to see detailed information
- **Transaction Flow**: Visualize inputs and outputs as flowing data
- **Fee Analysis**: Color-coded blocks based on fee rates

### 💎 UTXO Visualization
- **Interactive UTXOs**: Explore unspent transaction outputs in 3D
- **Value-based Scaling**: UTXO size reflects Bitcoin value
- **Address Grouping**: Organize UTXOs by address or script type

### 📊 Data Views
- **Mempool View**: Real-time pending transactions
- **Fee Market**: 3D fee distribution charts
- **Network Stats**: Live network statistics

## Usage Guide

### Basic Navigation
1. **Look and Point**: Use eye tracking to focus on objects
2. **Pinch**: Select and interact with blockchain elements
3. **Drag**: Move around the 3D space
4. **Voice Commands**: "Show me block 800,000" or "What's in the mempool?"

### Exploring Blocks
1. **Tap a Block**: Select a block to see its details
2. **View Transactions**: See transaction count and fee information
3. **Block Details**: Access timestamp, size, and mining pool info

### Transaction Analysis
1. **Select Transaction**: Tap on transaction spheres
2. **Input/Output Flow**: Watch animated connections between inputs and outputs
3. **Fee Analysis**: See fee rates and transaction sizes

### UTXO Exploration
1. **Address Search**: Enter a Bitcoin address to explore its UTXOs
2. **Value Filtering**: Filter UTXOs by value ranges
3. **Script Type Grouping**: Organize by P2PKH, P2SH, SegWit, etc.

## Development

### Project Structure
```
visionOS/
├── MempoolVisionOS/
│   ├── App.swift                 # App entry point
│   ├── ContentView.swift         # Main UI
│   ├── Models/                   # Data models
│   │   ├── Block.swift
│   │   ├── Transaction.swift
│   │   └── UTXO.swift
│   ├── Views/                    # SwiftUI views
│   │   └── Blockchain3DView.swift
│   ├── ViewModels/               # MVVM view models
│   │   └── BlockchainViewModel.swift
│   ├── Services/                 # API services
│   │   └── MempoolService.swift
│   └── Components/               # 3D components
│       ├── BlockEntity.swift
│       ├── TransactionFlow.swift
│       └── UTXOVisualizer.swift
```

### Key Components

#### Blockchain3DView
The main 3D visualization view using RealityKit:
- Renders blockchain data in 3D space
- Handles user interactions
- Manages camera and lighting

#### BlockEntity
Individual Bitcoin block representation:
- 3D geometry with materials
- Interactive selection
- Animation support

#### TransactionFlow
Transaction input/output visualization:
- Animated connections
- Fee rate coloring
- Detailed transaction info

#### UTXOVisualizer
UTXO exploration component:
- Multiple visualization modes
- Value-based scaling
- Interactive filtering

### API Integration
The app integrates with mempool.space API endpoints:
- `/api/v1/blocks` - Recent blocks
- `/api/v1/block/{hash}` - Block details
- `/api/v1/tx/{txid}` - Transaction details
- `/api/v1/address/{address}/utxo` - Address UTXOs
- `/api/v1/mempool/recent` - Recent mempool transactions

## Customization

### Visual Themes
Modify colors and materials in the component files:
```swift
// In BlockEntity.swift
private func colorForFeeRate(_ feeRate: Double) -> UIColor {
    if feeRate > 100 { return .red }
    else if feeRate > 50 { return .orange }
    // ... customize colors
}
```

### Data Sources
Update API endpoints in `MempoolService.swift`:
```swift
// Use your own mempool instance
private let baseURL = "https://your-instance.com/api"
```

### 3D Layouts
Modify positioning and scaling in visualization components:
```swift
// In Blockchain3DView.swift
private func calculatePosition(for block: Block) -> SIMD3<Float> {
    // Customize 3D positioning logic
}
```

## Troubleshooting

### Common Issues

#### Build Errors
- **SDK Version**: Ensure Xcode 15.0+ with visionOS SDK
- **Signing**: Check Apple Developer account and provisioning profiles
- **Dependencies**: Clean build folder (Cmd+Shift+K) and rebuild

#### Runtime Issues
- **API Errors**: Check network connectivity and API endpoint
- **Performance**: Reduce number of visible entities for better performance
- **Memory**: Monitor memory usage with large datasets

#### Device Issues
- **Installation**: Ensure device is unlocked and trusted
- **Permissions**: Grant necessary permissions when prompted
- **Updates**: Keep visionOS updated to latest version

### Performance Optimization
1. **Limit Entity Count**: Show max 100-200 entities at once
2. **Level of Detail**: Reduce detail for distant objects
3. **Animation Throttling**: Limit concurrent animations
4. **Memory Management**: Release unused resources

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on simulator and device
5. Submit a pull request

### Code Style
- Follow Swift style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Include unit tests for new features

### Testing
- Test on Vision Pro Simulator
- Test on physical Vision Pro device
- Test with different network conditions
- Test with various data sizes

## Support

### Documentation
- [Apple Vision Pro Developer Documentation](https://developer.apple.com/visionos/)
- [RealityKit Framework Reference](https://developer.apple.com/documentation/realitykit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Community
- [Mempool.space Community](https://github.com/mempool/mempool)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Vision Pro Developer Discord](https://discord.gg/visionpro)

### Issues
Report bugs and feature requests:
1. Check existing issues first
2. Provide detailed reproduction steps
3. Include device/simulator information
4. Attach relevant logs and screenshots

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on the foundation of [mempool.space](https://mempool.space)
- Inspired by the Bitcoin community's passion for transparency
- Made possible by Apple's visionOS platform
- Thanks to all contributors and the open-source community

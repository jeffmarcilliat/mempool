# Mempool VisionOS - Immersive Blockchain Explorer

An immersive visionOS application that brings the Bitcoin blockchain to life in spatial computing. Explore blocks, transactions, and UTXOs in a truly three-dimensional, interactive environment.

## 🌟 Key Features

### 🏗️ **3D Blockchain Visualization**
- **Immersive Chain View**: Walk through the blockchain as a 3D chain of connected blocks
- **Spatial Navigation**: Use hand gestures and eye tracking to navigate through blocks
- **Real-time Updates**: Live mempool and block confirmations in your spatial environment

### 🔍 **Block Exploration**
- **Block Inspection**: Dive into individual blocks and see their structure in 3D
- **Transaction Flow**: Visualize transaction inputs and outputs as flowing data streams
- **UTXO Visualization**: Explore unspent transaction outputs as interactive 3D objects

### 💎 **Interactive Elements**
- **Gesture Controls**: Pinch, drag, and point to interact with blockchain data
- **Voice Commands**: "Show me block 800,000" or "What's in the mempool?"
- **Spatial Audio**: Hear the blockchain with spatialized audio feedback

### 📊 **Data Visualization**
- **Fee Market**: 3D fee distribution charts floating in space
- **Mining Pools**: Visual representation of mining pool contributions
- **Network Health**: Real-time network statistics in immersive displays

## 🏗️ Project Structure

```
visionOS/
├── MempoolVisionOS/           # Main visionOS app
│   ├── App.swift              # App entry point
│   ├── ContentView.swift      # Main content view
│   ├── Models/                # Data models
│   ├── Views/                 # SwiftUI views
│   ├── ViewModels/            # MVVM view models
│   ├── Services/              # API and data services
│   ├── Components/            # Reusable 3D components
│   └── Resources/             # Assets and resources
├── Shared/                    # Shared code between platforms
│   ├── Models/                # Shared data models
│   ├── Services/              # Shared API services
│   └── Utils/                 # Shared utilities
└── Tests/                     # Unit and integration tests
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ / visionOS 1.0+
- Apple Developer Account (for device testing)

### Installation
1. Clone the repository
2. Open `MempoolVisionOS.xcodeproj` in Xcode
3. Select your target device (Vision Pro simulator or device)
4. Build and run the project

### Configuration
- Set your mempool.space API endpoint in `Config.swift`
- Configure network settings (mainnet/testnet) as needed

## 🎯 Core Components

### Blockchain3DView
The main 3D view that renders the blockchain as an interactive spatial experience.

### BlockEntity
3D representation of a Bitcoin block with:
- Block header visualization
- Transaction count display
- Fee information
- Mining pool attribution

### TransactionFlow
Interactive visualization of transaction inputs and outputs as flowing data streams.

### UTXOVisualizer
3D representation of unspent transaction outputs with:
- Value visualization
- Address information
- Spending status

## 🔧 Architecture

The app follows MVVM architecture with:
- **Models**: Data structures for blocks, transactions, UTXOs
- **ViewModels**: Business logic and state management
- **Views**: SwiftUI views for 2D UI elements
- **RealityKit**: 3D scene management and rendering
- **Services**: API communication and data processing

## 🌐 API Integration

The app integrates with the existing mempool.space API to provide:
- Real-time blockchain data
- Mempool information
- Transaction details
- Network statistics

## 🎨 Design Principles

- **Spatial Computing First**: Designed specifically for visionOS capabilities
- **Intuitive Interaction**: Natural gestures and voice commands
- **Information Density**: Efficient use of 3D space for data display
- **Accessibility**: Support for various interaction methods

## 🔮 Future Enhancements

- **Multi-chain Support**: Ethereum, Liquid, and other blockchains
- **Social Features**: Shared spatial experiences with other users
- **Advanced Analytics**: Machine learning-powered insights
- **Custom Environments**: User-defined spatial workspaces

## 📱 Platform Support

- **visionOS**: Full immersive experience
- **iOS**: Companion app with basic functionality
- **macOS**: Developer tools and analytics

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for details on:
- Code style and standards
- Testing requirements
- Pull request process
- Community guidelines

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built on the foundation of the mempool.space project
- Inspired by the Bitcoin community's passion for transparency
- Made possible by Apple's visionOS platform

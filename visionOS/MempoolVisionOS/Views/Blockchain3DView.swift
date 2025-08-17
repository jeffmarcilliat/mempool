import SwiftUI
import RealityKit
import Combine

struct Blockchain3DView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    @State private var rootEntity: Entity?
    
    var body: some View {
        ZStack {
            // 3D Scene
            RealityView { content in
                setupScene(content: content)
            } update: { content in
                updateScene(content: content)
            }
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        handleTap(at: value.location)
                    }
            )
            
            // Overlay UI
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button("Reset Camera") {
                            viewModel.resetCamera()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Latest Block") {
                            viewModel.goToLatestBlock()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Mempool") {
                            viewModel.showMempool()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView("Loading blockchain data...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.clearError()
                        }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Scene Setup
    
    private func setupScene(content: RealityViewContent) {
        // Create main root entity
        let rootEntity = Entity()
        rootEntity.name = "BlockchainRoot"
        
        // Add lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        directionalLight.position = SIMD3<Float>(5, 5, 5)
        rootEntity.addChild(directionalLight)
        
        // Add ambient light
        let ambientLight = DirectionalLight()
        ambientLight.light.intensity = 200
        ambientLight.position = SIMD3<Float>(0, 1, 0)
        rootEntity.addChild(ambientLight)
        
        // Store reference
        self.rootEntity = rootEntity
        
        content.add(rootEntity)
    }
    
    private func updateScene(content: RealityViewContent) {
        guard let rootEntity = rootEntity else { return }
        
        // Clear existing blockchain entities
        rootEntity.children.removeAll { entity in
            entity.name.hasPrefix("block_") || entity.name.hasPrefix("chain_") || 
            entity.name.hasPrefix("mempool_") || entity.name.hasPrefix("fee_") ||
            entity.name.hasPrefix("detail_") || entity.name.hasPrefix("utxo_")
        }
        
        // Add blockchain visualization based on current view
        switch viewModel.currentView {
        case .chain:
            addBlockchainChain(to: rootEntity)
        case .mempool:
            addMempoolVisualization(to: rootEntity)
        case .feeMarket:
            addFeeMarketVisualization(to: rootEntity)
        case .blockDetail:
            addBlockDetailVisualization(to: rootEntity)
        case .transactionDetail:
            addTransactionDetailVisualization(to: rootEntity)
        case .utxoExplorer:
            addUTXOExplorerVisualization(to: rootEntity)
        case .blockchain, .transaction, .utxo:
            addBlockchainChain(to: rootEntity)
        }
    }
    
    // MARK: - Visualization Methods
    
    private func addBlockchainChain(to parentEntity: Entity) {
        let chainAnchor = Entity()
        chainAnchor.name = "blockchain_chain"
        
        for (index, block) in viewModel.blocks.enumerated() {
            let blockEntity = createBlockEntity(for: block, at: index)
            chainAnchor.addChild(blockEntity)
            
            // Connect to previous block
            if index > 0 {
                let connectionEntity = createConnectionEntity(
                    from: blockEntity.position,
                    to: chainAnchor.children[index - 1].position
                )
                chainAnchor.addChild(connectionEntity)
            }
        }
        
        parentEntity.addChild(chainAnchor)
    }
    
    private func addMempoolVisualization(to parentEntity: Entity) {
        let mempoolAnchor = Entity()
        mempoolAnchor.name = "mempool_visualization"
        
        // Create a 3D scatter plot of mempool transactions
        for (index, transaction) in viewModel.mempoolTransactions.prefix(100).enumerated() {
            let txEntity = createTransactionEntity(for: transaction, at: index)
            mempoolAnchor.addChild(txEntity)
        }
        
        parentEntity.addChild(mempoolAnchor)
    }
    
    private func addFeeMarketVisualization(to parentEntity: Entity) {
        let feeAnchor = Entity()
        feeAnchor.name = "fee_market_visualization"
        
        // Create 3D fee distribution chart
        let feeDistribution = viewModel.feeDistribution
        var yOffset: Float = 0
        
        for (index, feeRate) in feeDistribution.enumerated() {
            let barEntity = createFeeBarEntity(
                label: "\(Int(feeRate))",
                count: Int(feeRate * 100),
                at: yOffset
            )
            feeAnchor.addChild(barEntity)
            yOffset += 0.5
        }
        
        parentEntity.addChild(feeAnchor)
    }
    
    private func addBlockDetailVisualization(to parentEntity: Entity) {
        guard let selectedBlock = viewModel.selectedBlock else { return }
        
        let detailAnchor = Entity()
        detailAnchor.name = "block_detail_visualization"
        
        // Create detailed block visualization
        let blockDetailEntity = createDetailedBlockEntity(for: selectedBlock)
        detailAnchor.addChild(blockDetailEntity)
        
        parentEntity.addChild(detailAnchor)
    }
    
    private func addTransactionDetailVisualization(to parentEntity: Entity) {
        guard let selectedTransaction = viewModel.selectedTransaction else { return }
        
        let detailAnchor = Entity()
        detailAnchor.name = "transaction_detail_visualization"
        
        // Create transaction flow visualization
        let transactionFlowEntity = createTransactionFlowEntity(for: selectedTransaction)
        detailAnchor.addChild(transactionFlowEntity)
        
        parentEntity.addChild(detailAnchor)
    }
    
    private func addUTXOExplorerVisualization(to parentEntity: Entity) {
        let utxoAnchor = Entity()
        utxoAnchor.name = "utxo_explorer_visualization"
        
        // Create UTXO visualization
        for (index, utxo) in viewModel.selectedUTXOs.enumerated() {
            let utxoEntity = createUTXOEntity(for: utxo, at: index)
            utxoAnchor.addChild(utxoEntity)
        }
        
        parentEntity.addChild(utxoAnchor)
    }
    
    // MARK: - Entity Creation
    
    private func createBlockEntity(for block: Block, at index: Int) -> Entity {
        let entity = Entity()
        entity.name = "block_\(block.height)"
        
        // Create block geometry
        let mesh = MeshResource.generateBox(size: block.visualSize)
        var material = SimpleMaterial()
        
        // Extract RGB values from UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        colorForFeeRate(block.feeRate).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        material.baseColor = .init(_colorLiteralRed: Float(red), 
                                 green: Float(green), 
                                 blue: Float(blue), 
                                 alpha: Float(alpha))
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position block
        entity.position = SIMD3<Float>(Float(index) * 0.3, 0, 0)
        entity.addChild(modelEntity)
        
        // Add text label
        let textEntity = createTextEntity(text: "\(block.height)", size: 0.05)
        textEntity.position = SIMD3<Float>(0, block.visualSize + 0.05, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createTransactionEntity(for transaction: Transaction, at index: Int) -> Entity {
        let entity = Entity()
        entity.name = "tx_\(transaction.id.prefix(8))"
        
        // Create transaction geometry
        let mesh = MeshResource.generateSphere(radius: transaction.visualSize)
        var material = SimpleMaterial()
        
        // Extract RGB values from UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        colorForFeeRate(transaction.feeRate).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        material.baseColor = .init(_colorLiteralRed: Float(red), 
                                 green: Float(green), 
                                 blue: Float(blue), 
                                 alpha: Float(alpha))
        material.metallic = 1.0
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position in 3D space based on fee rate and size
        let x = Float(index % 10) * 0.2
        let y = Float(transaction.feeRate) * 0.01
        let z = Float(index / 10) * 0.2
        entity.position = SIMD3<Float>(x, y, z)
        entity.addChild(modelEntity)
        
        return entity
    }
    
    private func createFeeBarEntity(label: String, count: Int, at yOffset: Float) -> Entity {
        let entity = Entity()
        entity.name = "fee_bar_\(label)"
        
        // Create bar geometry
        let height = Float(count) * 0.01
        let mesh = MeshResource.generateBox(size: [0.1, height, 0.1])
        var material = SimpleMaterial()
        material.baseColor = .init(_colorLiteralRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.position = SIMD3<Float>(0, height / 2 + yOffset, 0)
        entity.addChild(modelEntity)
        
        // Add label
        let textEntity = createTextEntity(text: "\(count)", size: 0.03)
        textEntity.position = SIMD3<Float>(0.15, height / 2, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createDetailedBlockEntity(for block: Block) -> Entity {
        let entity = Entity()
        entity.name = "detailed_block_\(block.height)"
        
        // Create larger block representation
        let mesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
        var material = SimpleMaterial()
        
        // Extract RGB values from UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        colorForFeeRate(block.feeRate).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        material.baseColor = .init(_colorLiteralRed: Float(red), 
                                 green: Float(green), 
                                 blue: Float(blue), 
                                 alpha: Float(alpha))
        material.metallic = 1.0
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.addChild(modelEntity)
        
        // Add detailed information
        let infoText = """
        Block \(block.height)
        \(block.txCount) transactions
        \(String(format: "%.2f", block.feeRate)) sat/vB
        """
        
        let textEntity = createTextEntity(text: infoText, size: 0.05)
        textEntity.position = SIMD3<Float>(0, 0.4, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createTransactionFlowEntity(for transaction: Transaction) -> Entity {
        let entity = Entity()
        entity.name = "transaction_flow_\(transaction.id.prefix(8))"
        
        // Create input and output representations
        let inputCount = transaction.vin.count
        let outputCount = transaction.vout.count
        
        // Input side
        for (index, _) in transaction.vin.enumerated() {
            let inputEntity = createInputOutputEntity(
                label: "Input \(index + 1)",
                color: .red,
                at: SIMD3<Float>(-0.3, Float(index) * 0.1, 0)
            )
            entity.addChild(inputEntity)
        }
        
        // Output side
        for (index, output) in transaction.vout.enumerated() {
            let outputEntity = createInputOutputEntity(
                label: "\(String(format: "%.8f", Double(output.value) / 100_000_000.0)) BTC",
                color: .green,
                at: SIMD3<Float>(0.3, Float(index) * 0.1, 0)
            )
            entity.addChild(outputEntity)
        }
        
        return entity
    }
    
    private func createUTXOEntity(for utxo: UTXO, at index: Int) -> Entity {
        let entity = Entity()
        entity.name = "utxo_\(utxo.id)"
        
        // Create UTXO geometry
        let mesh = MeshResource.generateSphere(radius: utxo.visualSize)
        var material = SimpleMaterial()
        
        // Extract RGB values from UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        colorForValue(utxo.value).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        material.baseColor = .init(_colorLiteralRed: Float(red), 
                                 green: Float(green), 
                                 blue: Float(blue), 
                                 alpha: Float(alpha))
        material.metallic = 1.0
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position in grid
        let x = Float(index % 5) * 0.3
        let y = Float(index / 5) * 0.3
        entity.position = SIMD3<Float>(x, y, 0)
        entity.addChild(modelEntity)
        
        // Add value label
        let valueText = String(format: "%.8f", utxo.btcValue)
        let textEntity = createTextEntity(text: valueText, size: 0.02)
        textEntity.position = SIMD3<Float>(0, utxo.visualSize + 0.03, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createInputOutputEntity(label: String, color: UIColor, at position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        
        let mesh = MeshResource.generateSphere(radius: 0.05)
        var material = SimpleMaterial()
        
        // Extract RGB values from UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        material.baseColor = .init(_colorLiteralRed: Float(red), 
                                 green: Float(green), 
                                 blue: Float(blue), 
                                 alpha: Float(alpha))
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.position = position
        entity.addChild(modelEntity)
        
        let textEntity = createTextEntity(text: label, size: 0.03)
        textEntity.position = SIMD3<Float>(0, 0.08, 0)
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createConnectionEntity(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
        let entity = Entity()
        
        let direction = to - from
        let distance = length(direction)
        let center = (from + to) / 2
        
        let mesh = MeshResource.generateBox(size: [0.02, 0.02, distance])
        var material = SimpleMaterial()
        material.baseColor = .init(_colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.position = center
        entity.look(at: to, from: from, relativeTo: nil)
        entity.addChild(modelEntity)
        
        return entity
    }
    
    private func createTextEntity(text: String, size: Float) -> Entity {
        let entity = Entity()
        
        // Create text mesh (simplified - in real implementation you'd use TextMeshResource)
        let mesh = MeshResource.generateBox(size: [size * Float(text.count) * 0.6, size, 0.01])
        var material = SimpleMaterial()
        material.baseColor = .init(_colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.addChild(modelEntity)
        
        return entity
    }
    
    // MARK: - Utility Methods
    
    private func colorForFeeRate(_ feeRate: Double) -> UIColor {
        if feeRate > 100 {
            return .red
        } else if feeRate > 50 {
            return .orange
        } else if feeRate > 20 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private func colorForValue(_ value: Int) -> UIColor {
        if value > 1_000_000_000 { // > 10 BTC
            return .systemYellow
        } else if value > 100_000_000 { // > 1 BTC
            return .orange
        } else if value > 10_000_000 { // > 0.1 BTC
            return .green
        } else {
            return .blue
        }
    }
    
    private func handleTap(at location: CGPoint) {
        // Handle tap interactions with 3D objects
        // This would involve ray casting to detect which object was tapped
        print("Tapped at: \(location)")
    }
}

#Preview {
    Blockchain3DView(viewModel: BlockchainViewModel())
}

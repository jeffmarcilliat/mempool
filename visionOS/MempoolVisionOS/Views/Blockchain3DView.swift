import SwiftUI
import RealityKit
import Combine

struct Blockchain3DView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    @State private var scene: RealityKit.Scene?
    @State private var cameraAnchor: AnchorEntity?
    
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
        .onAppear {
            setupInitialScene()
        }
    }
    
    // MARK: - Scene Setup
    
    private func setupScene(content: RealityViewContent) {
        // Create main scene
        let scene = RealityKit.Scene()
        
        // Add lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        directionalLight.look(at: [0, 0, 0], from: [5, 5, 5], relativeTo: nil)
        scene.addChild(directionalLight)
        
        // Add ambient light
        let ambientLight = DirectionalLight()
        ambientLight.light.intensity = 200
        ambientLight.look(at: [0, 0, 0], from: [0, 1, 0], relativeTo: nil)
        scene.addChild(ambientLight)
        
        // Create camera anchor
        let cameraAnchor = AnchorEntity(.camera)
        let camera = PerspectiveCamera()
        cameraAnchor.addChild(camera)
        scene.addChild(cameraAnchor)
        
        // Store references
        self.scene = scene
        self.cameraAnchor = cameraAnchor
        
        content.add(scene)
    }
    
    private func setupInitialScene() {
        // Initial scene setup will be handled in updateScene
    }
    
    private func updateScene(content: RealityViewContent) {
        guard let scene = scene else { return }
        
        // Clear existing blockchain entities
        scene.children.removeAll { entity in
            entity.name.hasPrefix("block_") || entity.name.hasPrefix("chain_")
        }
        
        // Add blockchain visualization based on current view
        switch viewModel.currentView {
        case .chain:
            addBlockchainChain(to: scene)
        case .mempool:
            addMempoolVisualization(to: scene)
        case .feeMarket:
            addFeeMarketVisualization(to: scene)
        case .blockDetail:
            addBlockDetailVisualization(to: scene)
        case .transactionDetail:
            addTransactionDetailVisualization(to: scene)
        case .utxoExplorer:
            addUTXOExplorerVisualization(to: scene)
        }
        
        // Update camera position
        updateCameraPosition()
    }
    
    // MARK: - Visualization Methods
    
    private func addBlockchainChain(to scene: RealityKit.Scene) {
        let chainAnchor = AnchorEntity()
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
        
        scene.addChild(chainAnchor)
    }
    
    private func addMempoolVisualization(to scene: RealityKit.Scene) {
        let mempoolAnchor = AnchorEntity()
        mempoolAnchor.name = "mempool_visualization"
        
        // Create a 3D scatter plot of mempool transactions
        for (index, transaction) in viewModel.mempoolTransactions.prefix(100).enumerated() {
            let txEntity = createTransactionEntity(for: transaction, at: index)
            mempoolAnchor.addChild(txEntity)
        }
        
        scene.addChild(mempoolAnchor)
    }
    
    private func addFeeMarketVisualization(to scene: RealityKit.Scene) {
        let feeAnchor = AnchorEntity()
        feeAnchor.name = "fee_market_visualization"
        
        // Create 3D fee distribution chart
        let feeDistribution = viewModel.feeDistribution
        var yOffset: Float = 0
        
        for (feeRange, count) in feeDistribution {
            let barEntity = createFeeBarEntity(
                label: feeRange,
                count: count,
                at: yOffset
            )
            feeAnchor.addChild(barEntity)
            yOffset += 0.5
        }
        
        scene.addChild(feeAnchor)
    }
    
    private func addBlockDetailVisualization(to scene: RealityKit.Scene) {
        guard let selectedBlock = viewModel.selectedBlock else { return }
        
        let detailAnchor = AnchorEntity()
        detailAnchor.name = "block_detail_visualization"
        
        // Create detailed block visualization
        let blockDetailEntity = createDetailedBlockEntity(for: selectedBlock)
        detailAnchor.addChild(blockDetailEntity)
        
        scene.addChild(detailAnchor)
    }
    
    private func addTransactionDetailVisualization(to scene: RealityKit.Scene) {
        guard let selectedTransaction = viewModel.selectedTransaction else { return }
        
        let detailAnchor = AnchorEntity()
        detailAnchor.name = "transaction_detail_visualization"
        
        // Create transaction flow visualization
        let transactionFlowEntity = createTransactionFlowEntity(for: selectedTransaction)
        detailAnchor.addChild(transactionFlowEntity)
        
        scene.addChild(detailAnchor)
    }
    
    private func addUTXOExplorerVisualization(to scene: RealityKit.Scene) {
        let utxoAnchor = AnchorEntity()
        utxoAnchor.name = "utxo_explorer_visualization"
        
        // Create UTXO visualization
        for (index, utxo) in viewModel.selectedUTXOs.enumerated() {
            let utxoEntity = createUTXOEntity(for: utxo, at: index)
            utxoAnchor.addChild(utxoEntity)
        }
        
        scene.addChild(utxoAnchor)
    }
    
    // MARK: - Entity Creation
    
    private func createBlockEntity(for block: Block, at index: Int) -> Entity {
        let entity = Entity()
        entity.name = "block_\(block.height)"
        
        // Create block geometry
        let mesh = MeshResource.generateBox(size: block.visualSize)
        let material = SimpleMaterial(color: colorForFeeRate(block.feeRate), isMetallic: false)
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
        let material = SimpleMaterial(color: colorForFeeRate(transaction.feeRate), isMetallic: true)
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
        let material = SimpleMaterial(color: .blue, isMetallic: false)
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
        let material = SimpleMaterial(color: colorForFeeRate(block.feeRate), isMetallic: true)
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
        let material = SimpleMaterial(color: colorForValue(utxo.value), isMetallic: true)
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
        let material = SimpleMaterial(color: color, isMetallic: false)
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
        let material = SimpleMaterial(color: .gray, isMetallic: false)
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
        let material = SimpleMaterial(color: .white, isMetallic: false)
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
    
    private func updateCameraPosition() {
        guard let cameraAnchor = cameraAnchor else { return }
        
        withAnimation(.easeInOut(duration: 2.0)) {
            cameraAnchor.position = viewModel.cameraPosition
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

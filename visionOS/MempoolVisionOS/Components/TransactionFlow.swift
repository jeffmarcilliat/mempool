import RealityKit
import SwiftUI
import Combine

class TransactionFlow: Entity {
    private let transaction: Transaction
    private var inputEntities: [Entity] = []
    private var outputEntities: [Entity] = []
    private var connectionEntities: [Entity] = []
    private var isAnimating = false
    
    // Animation properties
    private var flowAnimation: AnimationResource?
    private var pulseAnimation: AnimationResource?
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init()
        
        setupTransactionFlow()
        setupAnimations()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupTransactionFlow() {
        name = "transaction_flow_\(transaction.id.prefix(8))"
        
        // Create input side
        setupInputs()
        
        // Create output side
        setupOutputs()
        
        // Create connections
        setupConnections()
        
        // Add transaction info
        setupTransactionInfo()
    }
    
    private func setupInputs() {
        let inputContainer = Entity()
        inputContainer.name = "input_container"
        inputContainer.position = SIMD3<Float>(-0.5, 0, 0)
        
        for (index, input) in transaction.vin.enumerated() {
            let inputEntity = createInputEntity(input: input, index: index)
            inputEntities.append(inputEntity)
            inputContainer.addChild(inputEntity)
        }
        
        addChild(inputContainer)
    }
    
    private func setupOutputs() {
        let outputContainer = Entity()
        outputContainer.name = "output_container"
        outputContainer.position = SIMD3<Float>(0.5, 0, 0)
        
        for (index, output) in transaction.vout.enumerated() {
            let outputEntity = createOutputEntity(output: output, index: index)
            outputEntities.append(outputEntity)
            outputContainer.addChild(outputEntity)
        }
        
        addChild(outputContainer)
    }
    
    private func setupConnections() {
        // Create animated connections from inputs to outputs
        // This is a simplified version - in reality, you'd map specific inputs to outputs
        
        let inputCount = inputEntities.count
        let outputCount = outputEntities.count
        
        for i in 0..<min(inputCount, outputCount) {
            let connectionEntity = createConnectionEntity(
                from: inputEntities[i].position,
                to: outputEntities[i].position
            )
            connectionEntities.append(connectionEntity)
            addChild(connectionEntity)
        }
    }
    
    private func setupTransactionInfo() {
        let infoContainer = Entity()
        infoContainer.name = "transaction_info"
        infoContainer.position = SIMD3<Float>(0, 0.3, 0)
        
        // Transaction ID
        let txIdText = "TX: \(transaction.id.prefix(16))..."
        let txIdEntity = createTextEntity(text: txIdText, size: 0.03)
        infoContainer.addChild(txIdEntity)
        
        // Fee information
        let feeText = "Fee: \(transaction.fee) sats (\(String(format: "%.2f", transaction.feeRate)) sat/vB)"
        let feeEntity = createTextEntity(text: feeText, size: 0.025)
        feeEntity.position = SIMD3<Float>(0, -0.04, 0)
        infoContainer.addChild(feeEntity)
        
        // Size information
        let sizeText = "Size: \(transaction.size) bytes, Weight: \(transaction.weight) WU"
        let sizeEntity = createTextEntity(text: sizeText, size: 0.025)
        sizeEntity.position = SIMD3<Float>(0, -0.08, 0)
        infoContainer.addChild(sizeEntity)
        
        addChild(infoContainer)
    }
    
    // MARK: - Entity Creation
    
    private func createInputEntity(input: TransactionInput, index: Int) -> Entity {
        let entity = Entity()
        entity.name = "input_\(index)"
        
        // Create input geometry
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position inputs vertically
        entity.position = SIMD3<Float>(0, Float(index) * 0.15, 0)
        entity.addChild(modelEntity)
        
        // Add input information
        let inputInfo = createInputInfo(input: input, index: index)
        inputInfo.position = SIMD3<Float>(0, 0.08, 0)
        entity.addChild(inputInfo)
        
        return entity
    }
    
    private func createOutputEntity(output: TransactionOutput, index: Int) -> Entity {
        let entity = Entity()
        entity.name = "output_\(index)"
        
        // Create output geometry
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .green, isMetallic: true)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position outputs vertically
        entity.position = SIMD3<Float>(0, Float(index) * 0.15, 0)
        entity.addChild(modelEntity)
        
        // Add output information
        let outputInfo = createOutputInfo(output: output, index: index)
        outputInfo.position = SIMD3<Float>(0, 0.08, 0)
        entity.addChild(outputInfo)
        
        return entity
    }
    
    private func createInputInfo(input: TransactionInput, index: Int) -> Entity {
        let entity = Entity()
        
        // Input label
        let label = input.isCoinbase ? "Coinbase" : "Input \(index + 1)"
        let labelEntity = createTextEntity(text: label, size: 0.02)
        entity.addChild(labelEntity)
        
        // Input value (if available)
        if let prevout = input.prevout {
            let valueText = String(format: "%.8f BTC", Double(prevout.value) / 100_000_000.0)
            let valueEntity = createTextEntity(text: valueText, size: 0.015)
            valueEntity.position = SIMD3<Float>(0, -0.025, 0)
            entity.addChild(valueEntity)
        }
        
        return entity
    }
    
    private func createOutputInfo(output: TransactionOutput, index: Int) -> Entity {
        let entity = Entity()
        
        // Output label
        let label = "Output \(index + 1)"
        let labelEntity = createTextEntity(text: label, size: 0.02)
        entity.addChild(labelEntity)
        
        // Output value
        let valueText = String(format: "%.8f BTC", Double(output.value) / 100_000_000.0)
        let valueEntity = createTextEntity(text: valueText, size: 0.015)
        valueEntity.position = SIMD3<Float>(0, -0.025, 0)
        entity.addChild(valueEntity)
        
        // Address type
        let typeText = output.scriptpubkeyType.uppercased()
        let typeEntity = createTextEntity(text: typeText, size: 0.012)
        typeEntity.position = SIMD3<Float>(0, -0.045, 0)
        entity.addChild(typeEntity)
        
        return entity
    }
    
    private func createConnectionEntity(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.name = "connection"
        
        // Create animated connection line
        let direction = to - from
        let distance = length(direction)
        let center = (from + to) / 2
        
        let mesh = MeshResource.generateBox(size: [0.01, 0.01, distance])
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.position = center
        entity.look(at: to, from: from, relativeTo: nil)
        entity.addChild(modelEntity)
        
        // Add glow effect
        let glowMesh = MeshResource.generateBox(size: [0.015, 0.015, distance])
        var glowMaterial = SimpleMaterial()
        glowMaterial.color = .blue
        glowMaterial.emissiveColor = .blue
        glowMaterial.emissiveIntensity = 0.3
        glowMaterial.transparency = .init(0.5)
        
        let glowEntity = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        glowEntity.isEnabled = false // Will be enabled during animation
        entity.addChild(glowEntity)
        
        return entity
    }
    
    private func createTextEntity(text: String, size: Float) -> Entity {
        let entity = Entity()
        
        // Create text mesh (simplified - in real implementation you'd use TextMeshResource)
        let textMesh = MeshResource.generateBox(size: [size * Float(text.count) * 0.6, size, 0.01])
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let modelEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        entity.addChild(modelEntity)
        
        return entity
    }
    
    // MARK: - Animations
    
    private func setupAnimations() {
        // Flow animation - particles flowing from inputs to outputs
        flowAnimation = AnimationResource.generate(with: .easeInOut(duration: 3.0).repeatForever()) { context in
            context.relativeTransform.translation = [1.0, 0, 0]
        }
        
        // Pulse animation for connections
        pulseAnimation = AnimationResource.generate(with: .easeInOut(duration: 1.0).repeatForever()) { context in
            context.relativeTransform.scale = [1.2, 1.2, 1.2]
        }
    }
    
    func startFlowAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Animate connections
        for connectionEntity in connectionEntities {
            guard let flowAnimation = flowAnimation else { continue }
            connectionEntity.playAnimation(flowAnimation, transitionDuration: 0.5)
            
            // Enable glow effect
            if let glowEntity = connectionEntity.children.first {
                glowEntity.isEnabled = true
            }
        }
        
        // Animate inputs and outputs
        animateInputsAndOutputs()
    }
    
    func stopFlowAnimation() {
        isAnimating = false
        
        // Stop all animations
        for connectionEntity in connectionEntities {
            connectionEntity.stopAllAnimations()
            
            // Disable glow effect
            if let glowEntity = connectionEntity.children.first {
                glowEntity.isEnabled = false
            }
        }
        
        // Stop input/output animations
        for entity in inputEntities + outputEntities {
            entity.stopAllAnimations()
        }
    }
    
    private func animateInputsAndOutputs() {
        // Animate inputs pulsing
        for (index, inputEntity) in inputEntities.enumerated() {
            let delay = Double(index) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.pulseEntity(inputEntity)
            }
        }
        
        // Animate outputs pulsing
        for (index, outputEntity) in outputEntities.enumerated() {
            let delay = Double(index) * 0.2 + 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.pulseEntity(outputEntity)
            }
        }
    }
    
    private func pulseEntity(_ entity: Entity) {
        guard let pulseAnimation = pulseAnimation else { return }
        entity.playAnimation(pulseAnimation, transitionDuration: 0.3)
    }
    
    // MARK: - Public Methods
    
    func highlightInput(_ index: Int) {
        guard index < inputEntities.count else { return }
        
        let inputEntity = inputEntities[index]
        let highlightAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.5)) { context in
            context.relativeTransform.scale = [1.5, 1.5, 1.5]
        }
        inputEntity.playAnimation(highlightAnimation, transitionDuration: 0.3)
    }
    
    func highlightOutput(_ index: Int) {
        guard index < outputEntities.count else { return }
        
        let outputEntity = outputEntities[index]
        let highlightAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.5)) { context in
            context.relativeTransform.scale = [1.5, 1.5, 1.5]
        }
        outputEntity.playAnimation(highlightAnimation, transitionDuration: 0.3)
    }
    
    func showUTXODetails(for inputIndex: Int) {
        guard inputIndex < transaction.vin.count else { return }
        
        let input = transaction.vin[inputIndex]
        if !input.isCoinbase, let prevout = input.prevout {
            // Show detailed UTXO information
            // This would create a detailed view of the UTXO being spent
            print("Showing UTXO details for input \(inputIndex): \(prevout.value) sats")
        }
    }
    
    func showAddressDetails(for outputIndex: Int) {
        guard outputIndex < transaction.vout.count else { return }
        
        let output = transaction.vout[outputIndex]
        if let address = output.scriptpubkeyAddress {
            // Show address details and UTXO creation
            print("Showing address details for output \(outputIndex): \(address)")
        }
    }
}

// MARK: - Transaction Flow Factory

class TransactionFlowFactory {
    static func createTransactionFlow(for transaction: Transaction, at position: SIMD3<Float>) -> TransactionFlow {
        let flow = TransactionFlow(transaction: transaction)
        flow.position = position
        return flow
    }
    
    static func createMempoolFlow(from transactions: [Transaction]) -> Entity {
        let container = Entity()
        container.name = "mempool_flow"
        
        for (index, transaction) in transactions.prefix(50).enumerated() {
            let flow = createTransactionFlow(for: transaction, at: SIMD3<Float>(
                Float(index % 5) * 0.4,
                Float(index / 5) * 0.4,
                0
            ))
            container.addChild(flow)
        }
        
        return container
    }
}

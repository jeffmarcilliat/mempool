import RealityKit
import SwiftUI
import Combine

class BlockEntity: Entity {
    private let block: Block
    private var modelEntity: ModelEntity?
    private var textEntity: Entity?
    private var glowEntity: Entity?
    private var isSelected = false
    
    // Animation properties
    private var rotationAnimation: AnimationResource?
    private var scaleAnimation: AnimationResource?
    private var glowAnimation: AnimationResource?
    
    init(block: Block) {
        self.block = block
        super.init()
        
        setupEntity()
        setupAnimations()
        setupInteractions()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupEntity() {
        name = "block_\(block.height)"
        
        // Create main block geometry
        let mesh = MeshResource.generateBox(size: block.visualSize)
        let material = createBlockMaterial()
        modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        if let modelEntity = modelEntity {
            addChild(modelEntity)
        }
        
        // Add block information text
        setupTextEntity()
        
        // Add glow effect
        setupGlowEffect()
        
        // Add transaction count indicator
        setupTransactionIndicator()
    }
    
    private func createBlockMaterial() -> RealityKit.Material {
        var material = SimpleMaterial()
        material.color = .init(colorForFeeRate(block.feeRate))
        material.metallic = 0.3
        material.roughness = 0.7
        
        // Add emission for selected blocks
        if isSelected {
            material.emissiveColor = .init(colorForFeeRate(block.feeRate))
            material.emissiveIntensity = 0.5
        }
        
        return material
    }
    
    private func setupTextEntity() {
        let textAnchor = AnchorEntity()
        textAnchor.name = "block_text_anchor"
        
        // Create text mesh for block height
        let heightText = "\(block.height)"
        let textMesh = MeshResource.generateBox(size: [0.1, 0.05, 0.01])
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let heightEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        textAnchor.addChild(heightEntity)
        textAnchor.position = SIMD3<Float>(0, block.visualSize + 0.1, 0)
        
        textEntity = textAnchor
        addChild(textAnchor)
    }
    
    private func setupGlowEffect() {
        let glowMesh = MeshResource.generateSphere(radius: block.visualSize * 1.2)
        var glowMaterial = SimpleMaterial()
        glowMaterial.color = .init(colorForFeeRate(block.feeRate))
        glowMaterial.emissiveColor = .init(colorForFeeRate(block.feeRate))
        glowMaterial.emissiveIntensity = 0.3
        glowMaterial.transparency = .init(0.3)
        
        let glowModel = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        glowEntity = glowModel
        addChild(glowModel)
        
        // Hide glow initially
        glowModel.isEnabled = false
    }
    
    private func setupTransactionIndicator() {
        // Create small spheres representing transactions
        let txCount = min(block.txCount, 20) // Limit for performance
        let radius = block.visualSize * 0.8
        
        for i in 0..<txCount {
            let angle = Float(i) * (2 * Float.pi) / Float(txCount)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            let txMesh = MeshResource.generateSphere(radius: 0.01)
            let txMaterial = SimpleMaterial(color: .blue, isMetallic: true)
            let txEntity = ModelEntity(mesh: txMesh, materials: [txMaterial])
            
            txEntity.position = SIMD3<Float>(x, 0, z)
            addChild(txEntity)
        }
    }
    
    // MARK: - Animations
    
    private func setupAnimations() {
        // Rotation animation
        rotationAnimation = AnimationResource.generate(with: .easeInOut(duration: 10.0)) { context in
            context.relativeTransform.rotation = simd_quatf(angle: .pi * 2, axis: [0, 1, 0])
        }
        
        // Scale animation for selection
        scaleAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.3)) { context in
            context.relativeTransform.scale = [1.2, 1.2, 1.2]
        }
        
        // Glow pulse animation
        glowAnimation = AnimationResource.generate(with: .easeInOut(duration: 2.0).repeatForever()) { context in
            context.relativeTransform.scale = [1.1, 1.1, 1.1]
        }
    }
    
    func startRotation() {
        guard let rotationAnimation = rotationAnimation else { return }
        modelEntity?.playAnimation(rotationAnimation, transitionDuration: 0.5)
    }
    
    func stopRotation() {
        modelEntity?.stopAllAnimations()
    }
    
    func select() {
        isSelected = true
        
        // Update material
        if let modelEntity = modelEntity {
            let material = createBlockMaterial()
            modelEntity.model?.materials = [material]
        }
        
        // Show glow
        glowEntity?.isEnabled = true
        
        // Scale up
        guard let scaleAnimation = scaleAnimation else { return }
        playAnimation(scaleAnimation, transitionDuration: 0.3)
        
        // Start glow pulse
        guard let glowAnimation = glowAnimation else { return }
        glowEntity?.playAnimation(glowAnimation, transitionDuration: 0.5)
    }
    
    func deselect() {
        isSelected = false
        
        // Update material
        if let modelEntity = modelEntity {
            let material = createBlockMaterial()
            modelEntity.model?.materials = [material]
        }
        
        // Hide glow
        glowEntity?.isEnabled = false
        glowEntity?.stopAllAnimations()
        
        // Scale down
        let scaleDownAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.3)) { context in
            context.relativeTransform.scale = [1.0, 1.0, 1.0]
        }
        playAnimation(scaleDownAnimation, transitionDuration: 0.3)
    }
    
    // MARK: - Interactions
    
    private func setupInteractions() {
        // Add collision component for tap detection
        let collisionComponent = CollisionComponent(shapes: [.generateBox(size: block.visualSize)])
        components.set(collisionComponent)
        
        // Add input target component
        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)
    }
    
    func handleTap() {
        // Toggle selection
        if isSelected {
            deselect()
        } else {
            select()
        }
        
        // Notify observers (this would be handled by the parent view)
        NotificationCenter.default.post(
            name: .blockTapped,
            object: self,
            userInfo: ["block": block]
        )
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
    
    // MARK: - Public Methods
    
    func updateBlock(_ newBlock: Block) {
        // Update block data and refresh visualization
        // This would be called when block data changes
    }
    
    func showTransactionFlow() {
        // Animate to show transaction flow visualization
        let flowAnimation = AnimationResource.generate(with: .easeInOut(duration: 1.0)) { context in
            context.relativeTransform.scale = [1.5, 1.5, 1.5]
        }
        playAnimation(flowAnimation, transitionDuration: 1.0)
    }
    
    func hideTransactionFlow() {
        // Animate back to normal size
        let hideAnimation = AnimationResource.generate(with: .easeInOut(duration: 1.0)) { context in
            context.relativeTransform.scale = [1.0, 1.0, 1.0]
        }
        playAnimation(hideAnimation, transitionDuration: 1.0)
    }
}

// MARK: - Extensions

extension Notification.Name {
    static let blockTapped = Notification.Name("blockTapped")
}

// MARK: - Block Entity Factory

class BlockEntityFactory {
    static func createBlockEntity(for block: Block, at position: SIMD3<Float>) -> BlockEntity {
        let entity = BlockEntity(block: block)
        entity.position = position
        return entity
    }
    
    static func createBlockchainChain(from blocks: [Block], spacing: Float = 0.3) -> Entity {
        let chainEntity = Entity()
        chainEntity.name = "blockchain_chain"
        
        for (index, block) in blocks.enumerated() {
            let position = SIMD3<Float>(Float(index) * spacing, 0, 0)
            let blockEntity = createBlockEntity(for: block, at: position)
            chainEntity.addChild(blockEntity)
            
            // Add connection to previous block
            if index > 0 {
                let connectionEntity = createConnectionEntity(
                    from: position,
                    to: SIMD3<Float>(Float(index - 1) * spacing, 0, 0)
                )
                chainEntity.addChild(connectionEntity)
            }
        }
        
        return chainEntity
    }
    
    private static func createConnectionEntity(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
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
}

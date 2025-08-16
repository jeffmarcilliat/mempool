import RealityKit
import SwiftUI
import Combine

class UTXOVisualizer: Entity {
    private let utxos: [UTXO]
    private var utxoEntities: [Entity] = []
    private var selectedUTXO: Entity?
    private var isGrouped = false
    
    // Visualization modes
    enum VisualizationMode {
        case scatter
        case grouped
        case timeline
        case valueBased
    }
    
    private var currentMode: VisualizationMode = .scatter
    
    init(utxos: [UTXO]) {
        self.utxos = utxos
        super.init()
        
        setupUTXOVisualizer()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUTXOVisualizer() {
        name = "utxo_visualizer"
        
        // Create UTXO entities
        createUTXOEntities()
        
        // Add summary information
        setupSummaryInfo()
        
        // Add controls
        setupControls()
    }
    
    private func createUTXOEntities() {
        for (index, utxo) in utxos.enumerated() {
            let utxoEntity = createUTXOEntity(for: utxo, at: index)
            utxoEntities.append(utxoEntity)
            addChild(utxoEntity)
        }
    }
    
    private func setupSummaryInfo() {
        let summaryContainer = Entity()
        summaryContainer.name = "utxo_summary"
        summaryContainer.position = SIMD3<Float>(0, 0.5, 0)
        
        // Total count
        let countText = "Total UTXOs: \(utxos.count)"
        let countEntity = createTextEntity(text: countText, size: 0.04)
        summaryContainer.addChild(countEntity)
        
        // Total value
        let totalValue = utxos.reduce(0) { $0 + $1.value }
        let valueText = String(format: "Total Value: %.8f BTC", Double(totalValue) / 100_000_000.0)
        let valueEntity = createTextEntity(text: valueText, size: 0.035)
        valueEntity.position = SIMD3<Float>(0, -0.05, 0)
        summaryContainer.addChild(valueEntity)
        
        // Average value
        let averageValue = totalValue / utxos.count
        let avgText = String(format: "Average: %.8f BTC", Double(averageValue) / 100_000_000.0)
        let avgEntity = createTextEntity(text: avgText, size: 0.03)
        avgEntity.position = SIMD3<Float>(0, -0.1, 0)
        summaryContainer.addChild(avgEntity)
        
        addChild(summaryContainer)
    }
    
    private func setupControls() {
        let controlsContainer = Entity()
        controlsContainer.name = "utxo_controls"
        controlsContainer.position = SIMD3<Float>(0, -0.5, 0)
        
        // Mode selection buttons (simplified as text entities)
        let modes = ["Scatter", "Grouped", "Timeline", "Value"]
        for (index, mode) in modes.enumerated() {
            let modeEntity = createTextEntity(text: mode, size: 0.025)
            modeEntity.position = SIMD3<Float>(Float(index - 2) * 0.15, 0, 0)
            controlsContainer.addChild(modeEntity)
        }
        
        addChild(controlsContainer)
    }
    
    // MARK: - Entity Creation
    
    private func createUTXOEntity(for utxo: UTXO, at index: Int) -> Entity {
        let entity = Entity()
        entity.name = "utxo_\(utxo.id)"
        
        // Create UTXO geometry based on value
        let mesh = MeshResource.generateSphere(radius: utxo.visualSize)
        let material = createUTXOMaterial(for: utxo)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Position based on current mode
        let position = calculatePosition(for: utxo, at: index)
        entity.position = position
        entity.addChild(modelEntity)
        
        // Add UTXO information
        let infoEntity = createUTXOInfo(for: utxo)
        infoEntity.position = SIMD3<Float>(0, utxo.visualSize + 0.05, 0)
        entity.addChild(infoEntity)
        
        // Add interaction components
        setupUTXOInteractions(entity: entity, utxo: utxo)
        
        return entity
    }
    
    private func createUTXOMaterial(for utxo: UTXO) -> Material {
        var material = SimpleMaterial()
        material.color = .init(colorForValue(utxo.value))
        material.metallic = 0.8
        material.roughness = 0.2
        
        // Add emission for high-value UTXOs
        if utxo.value > 100_000_000 { // > 1 BTC
            material.emissiveColor = .init(colorForValue(utxo.value))
            material.emissiveIntensity = 0.3
        }
        
        return material
    }
    
    private func createUTXOInfo(for utxo: UTXO) -> Entity {
        let entity = Entity()
        
        // Value
        let valueText = String(format: "%.8f", utxo.btcValue)
        let valueEntity = createTextEntity(text: valueText, size: 0.02)
        entity.addChild(valueEntity)
        
        // Address (shortened)
        if let address = utxo.scriptpubkeyAddress {
            let shortAddress = String(address.prefix(8)) + "..."
            let addressEntity = createTextEntity(text: shortAddress, size: 0.015)
            addressEntity.position = SIMD3<Float>(0, -0.025, 0)
            entity.addChild(addressEntity)
        }
        
        // Script type
        let typeText = utxo.scriptpubkeyType.uppercased()
        let typeEntity = createTextEntity(text: typeText, size: 0.012)
        typeEntity.position = SIMD3<Float>(0, -0.04, 0)
        entity.addChild(typeEntity)
        
        return entity
    }
    
    private func setupUTXOInteractions(entity: Entity, utxo: UTXO) {
        // Add collision component
        let collisionComponent = CollisionComponent(shapes: [.generateSphere(radius: utxo.visualSize)])
        entity.components.set(collisionComponent)
        
        // Add input target component
        let inputTargetComponent = InputTargetComponent()
        entity.components.set(inputTargetComponent)
        
        // Store UTXO reference
        entity.userData = ["utxo": utxo]
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
    
    // MARK: - Positioning
    
    private func calculatePosition(for utxo: UTXO, at index: Int) -> SIMD3<Float> {
        switch currentMode {
        case .scatter:
            return scatterPosition(at: index)
        case .grouped:
            return groupedPosition(for: utxo)
        case .timeline:
            return timelinePosition(for: utxo)
        case .valueBased:
            return valueBasedPosition(for: utxo)
        }
    }
    
    private func scatterPosition(at index: Int) -> SIMD3<Float> {
        // Random-like distribution in a sphere
        let radius = 2.0
        let angle1 = Float(index) * 0.1
        let angle2 = Float(index) * 0.2
        
        let x = cos(angle1) * cos(angle2) * radius
        let y = sin(angle1) * radius
        let z = cos(angle1) * sin(angle2) * radius
        
        return SIMD3<Float>(x, y, z)
    }
    
    private func groupedPosition(for utxo: UTXO) -> SIMD3<Float> {
        // Group by script type
        let scriptTypes = ["p2pkh", "p2sh", "v0_p2wpkh", "v0_p2wsh", "v1_p2tr"]
        let groupIndex = scriptTypes.firstIndex(of: utxo.scriptpubkeyType) ?? 0
        
        let x = Float(groupIndex - 2) * 0.5
        let y = Float(utxo.value) / 1_000_000_000.0 // Scale by value
        let z = 0.0
        
        return SIMD3<Float>(x, y, z)
    }
    
    private func timelinePosition(for utxo: UTXO) -> SIMD3<Float> {
        // Position based on block time
        let blockTime = utxo.blockTime ?? 0
        let currentTime = Int(Date().timeIntervalSince1970)
        let timeDiff = Float(currentTime - blockTime) / (365 * 24 * 3600) // Years ago
        
        let x = timeDiff * 0.5
        let y = Float(utxo.value) / 100_000_000.0 // BTC value
        let z = 0.0
        
        return SIMD3<Float>(x, y, z)
    }
    
    private func valueBasedPosition(for utxo: UTXO) -> SIMD3<Float> {
        // Position based on value ranges
        let valueRanges: [(min: Int, max: Int, x: Float)] = [
            (0, 1_000, -1.5),           // Dust
            (1_000, 10_000, -1.0),      // Small
            (10_000, 100_000, -0.5),    // Medium
            (100_000, 1_000_000, 0.0),  // Large
            (1_000_000, 10_000_000, 0.5), // Very Large
            (10_000_000, Int.max, 1.0)  // Huge
        ]
        
        let range = valueRanges.first { range in
            utxo.value >= range.min && utxo.value < range.max
        } ?? valueRanges.last!
        
        let x = range.x
        let y = Float(utxo.value) / 1_000_000_000.0
        let z = 0.0
        
        return SIMD3<Float>(x, y, z)
    }
    
    // MARK: - Public Methods
    
    func switchVisualizationMode(_ mode: VisualizationMode) {
        currentMode = mode
        
        // Animate to new positions
        for (index, entity) in utxoEntities.enumerated() {
            let newPosition = calculatePosition(for: utxos[index], at: index)
            
            withAnimation(.easeInOut(duration: 1.0)) {
                entity.position = newPosition
            }
        }
    }
    
    func selectUTXO(_ utxo: UTXO) {
        // Deselect previous
        if let selected = selectedUTXO {
            deselectUTXO(selected)
        }
        
        // Find and select new UTXO
        if let entity = utxoEntities.first(where: { entity in
            entity.userData["utxo"] as? UTXO == utxo
        }) {
            selectUTXO(entity)
        }
    }
    
    func filterByValueRange(min: Int, max: Int) {
        for (index, entity) in utxoEntities.enumerated() {
            let utxo = utxos[index]
            let isVisible = utxo.value >= min && utxo.value <= max
            
            withAnimation(.easeInOut(duration: 0.5)) {
                entity.isEnabled = isVisible
            }
        }
    }
    
    func filterByScriptType(_ scriptType: String) {
        for (index, entity) in utxoEntities.enumerated() {
            let utxo = utxos[index]
            let isVisible = utxo.scriptpubkeyType == scriptType
            
            withAnimation(.easeInOut(duration: 0.5)) {
                entity.isEnabled = isVisible
            }
        }
    }
    
    func showUTXODetails(_ utxo: UTXO) {
        // Create detailed view for the UTXO
        let detailEntity = createUTXODetailView(for: utxo)
        detailEntity.position = SIMD3<Float>(0, 0.8, 0)
        addChild(detailEntity)
    }
    
    // MARK: - Private Methods
    
    private func selectUTXO(_ entity: Entity) {
        selectedUTXO = entity
        
        // Scale up
        let scaleAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.3)) { context in
            context.relativeTransform.scale = [1.3, 1.3, 1.3]
        }
        entity.playAnimation(scaleAnimation, transitionDuration: 0.3)
        
        // Add glow effect
        addGlowEffect(to: entity)
    }
    
    private func deselectUTXO(_ entity: Entity) {
        // Scale down
        let scaleAnimation = AnimationResource.generate(with: .easeInOut(duration: 0.3)) { context in
            context.relativeTransform.scale = [1.0, 1.0, 1.0]
        }
        entity.playAnimation(scaleAnimation, transitionDuration: 0.3)
        
        // Remove glow effect
        removeGlowEffect(from: entity)
    }
    
    private func addGlowEffect(to entity: Entity) {
        let glowMesh = MeshResource.generateSphere(radius: 0.1)
        var glowMaterial = SimpleMaterial()
        glowMaterial.color = .yellow
        glowMaterial.emissiveColor = .yellow
        glowMaterial.emissiveIntensity = 0.5
        glowMaterial.transparency = .init(0.3)
        
        let glowEntity = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        glowEntity.name = "glow_effect"
        entity.addChild(glowEntity)
    }
    
    private func removeGlowEffect(from entity: Entity) {
        if let glowEntity = entity.children.first(where: { $0.name == "glow_effect" }) {
            glowEntity.removeFromParent()
        }
    }
    
    private func createUTXODetailView(for utxo: UTXO) -> Entity {
        let detailEntity = Entity()
        detailEntity.name = "utxo_detail_\(utxo.id)"
        
        // Background
        let backgroundMesh = MeshResource.generateBox(size: [0.8, 0.6, 0.1])
        let backgroundMaterial = SimpleMaterial(color: .black, isMetallic: false)
        let backgroundEntity = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        detailEntity.addChild(backgroundEntity)
        
        // Detailed information
        let infoTexts = [
            "UTXO: \(utxo.id)",
            "Value: \(String(format: "%.8f", utxo.btcValue)) BTC",
            "Address: \(utxo.scriptpubkeyAddress ?? "Unknown")",
            "Script Type: \(utxo.scriptpubkeyType)",
            "Block Height: \(utxo.blockHeight ?? 0)",
            "Block Time: \(utxo.blockTime ?? 0)"
        ]
        
        for (index, text) in infoTexts.enumerated() {
            let textEntity = createTextEntity(text: text, size: 0.025)
            textEntity.position = SIMD3<Float>(0, 0.2 - Float(index) * 0.08, 0.06)
            detailEntity.addChild(textEntity)
        }
        
        return detailEntity
    }
    
    private func colorForValue(_ value: Int) -> UIColor {
        if value > 1_000_000_000 { // > 10 BTC
            return .systemYellow
        } else if value > 100_000_000 { // > 1 BTC
            return .orange
        } else if value > 10_000_000 { // > 0.1 BTC
            return .green
        } else if value > 1_000_000 { // > 0.01 BTC
            return .blue
        } else {
            return .gray
        }
    }
}

// MARK: - UTXO Visualizer Factory

class UTXOVisualizerFactory {
    static func createUTXOVisualizer(from utxos: [UTXO], at position: SIMD3<Float>) -> UTXOVisualizer {
        let visualizer = UTXOVisualizer(utxos: utxos)
        visualizer.position = position
        return visualizer
    }
    
    static func createAddressUTXOVisualizer(for address: String, utxos: [UTXO]) -> Entity {
        let container = Entity()
        container.name = "address_utxo_visualizer"
        
        // Add address label
        let addressEntity = createTextEntity(text: "Address: \(address)", size: 0.04)
        addressEntity.position = SIMD3<Float>(0, 0.8, 0)
        container.addChild(addressEntity)
        
        // Add UTXO visualizer
        let visualizer = createUTXOVisualizer(from: utxos, at: SIMD3<Float>(0, 0, 0))
        container.addChild(visualizer)
        
        return container
    }
    
    private static func createTextEntity(text: String, size: Float) -> Entity {
        let entity = Entity()
        
        let textMesh = MeshResource.generateBox(size: [size * Float(text.count) * 0.6, size, 0.01])
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let modelEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        entity.addChild(modelEntity)
        
        return entity
    }
}

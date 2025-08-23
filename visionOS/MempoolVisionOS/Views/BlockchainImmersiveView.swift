import SwiftUI
import RealityKit
import ARKit

struct BlockchainImmersiveView: View {
    @Binding var immersionStyle: ImmersionStyle
    @StateObject private var viewModel = BlockchainViewModel()
    @State private var selectedBlockIndex: Int? = nil
    @State private var eyeTrackingTimer: Timer?
    @State private var rootEntity: Entity?
    @State private var lookedAtBlockIndex: Int?
    @State private var chainOffset: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @State private var baseChainDistance: Float = 0.0
    @State private var isInteracting = false
    @State private var lastDragTranslation = CGSize.zero
    @State private var chainVelocity: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @State private var decelerationTimer: Timer?
    @State private var lastDepthDeltaZ: Float = 0
    @State private var lastDepthUpdateTime: TimeInterval = 0
    @State private var lastMagnificationValue: CGFloat = 1.0
    @State private var mempoolStrata: [MempoolStrata] = []
    @State private var showMempoolView = false
    @State private var mempoolEntity: Entity?
    @State private var selectedStratum: MempoolStrata?
    
    // UI toggle for immersion style (Hashable for Picker)
    private enum ImmersionOption: String, CaseIterable, Hashable { case mixed, full }
    @State private var immersionOption: ImmersionOption = .mixed
    
    @State private var blockEntities: [String: ModelEntity] = [:] // Store references to block entities
    @State private var arSession: ARKitSession?
    @State private var worldTrackingProvider = WorldTrackingProvider()
    @State private var sceneReconstructionProvider = SceneReconstructionProvider(modes: [.classification])
    
    var body: some View {
            RealityView { content in
        // Create root entity
        let rootEntity = Entity()
        rootEntity.name = "blockchain_root"
        self.rootEntity = rootEntity // Store reference
        
        print("🏗️ RealityView make: Root entity created and stored")
            
            
            // TODO: Implement visionOS-compatible lighting when available
            // let directionalLight = DirectionalLight()
            // directionalLight.look(at: SIMD3<Float>(0, 0, -1), from: SIMD3<Float>(2, 3, 2), relativeTo: nil)
            // directionalLight.light.intensity = 8.0  // Very bright for crystal clear visibility
            // directionalLight.light.color = .white
            // rootEntity.addChild(directionalLight)
            
            // let ambientLight = DirectionalLight() // Changed from AmbientLight to DirectionalLight
            // ambientLight.light.intensity = 2.0  // Brighter ambient for better content visibility
            // ambientLight.light.color = .white
            // rootEntity.addChild(ambientLight)
            
            // let fillLight = DirectionalLight()
            // fillLight.look(at: SIMD3<Float>(0, 1, 0), from: SIMD3<Float>(0, -2, 0), relativeTo: nil)
            // fillLight.light.intensity = 3.0  // Moderate fill light
            // fillLight.light.color = .white
            // rootEntity.addChild(fillLight)
            
                                   // Always show loading text initially - blocks will be added via update closure
                       let loadingEntity = ModelEntity(
                           mesh: .generateText("Loading blockchain data...", extrusionDepth: 0.01, font: .systemFont(ofSize: 0.05)),
                           materials: [SimpleMaterial(color: .cyan, isMetallic: false)]
                       )
                       loadingEntity.position = SIMD3<Float>(0, 1.0, -1.0)
                       loadingEntity.name = "loading_text"
                       rootEntity.addChild(loadingEntity)
            
            content.add(rootEntity)
        } update: { content in
            guard let rootEntity = self.rootEntity else { return }
            
            // Debug: Print root entity info
            if rootEntity.children.count > 2 { // Only log if we have blocks (more than just lights and loading text)
                print("🔍 RealityView update: Root entity has \(rootEntity.children.count) children, chainOffset: \(chainOffset)")
            }
            
            // Only update position if not actively interacting (to avoid conflicts with real-time updates)
            if !isInteracting {
                rootEntity.transform.translation = chainOffset
            }
            
            // Update materials for selected/looked-at blocks (only if blocks exist)
            for (index, block) in viewModel.blocks.sorted(by: { $0.height > $1.height }).enumerated() {
                if let blockEntity = blockEntities[block.id] {
                    blockEntity.model?.materials = [createTranslucentMaterial(block: block, index: index)]
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    handleBlockSelection(at: value.location)
                }
        )
        .simultaneousGesture(
            // Enhanced magnification for depth control (Z-axis movement)
            MagnificationGesture()
                .onChanged { value in
                    // Use magnification for depth control (moving blocks closer/further)
                    handleDepthControl(magnification: value)
                }
                .onEnded { value in
                    // Handle both depth control end and finger tap
                    handleDepthControlEnd()
                    
                    // If magnification is close to 1.0, treat as finger tap
                    if abs(value - 1.0) < 0.1 {
                        handleFingerTap()
                    }
                }
        )
        .simultaneousGesture(
            // Simple drag gesture for X/Y movement (left/right, up/down)
            DragGesture()
                .onChanged { value in
                    handleChainDrag(translation: value.translation)
                }
                .onEnded { value in
                    handleChainDragEnd(velocity: value.velocity)
                }
        )
        .onTapGesture { location in
            // Alternative tap handling
            handleBlockSelection(at: location)
        }
        .overlay(alignment: .center) {
            VStack(spacing: 8) {
                Picker("Immersion", selection: $immersionOption) {
                    Text("Mixed").tag(ImmersionOption.mixed)
                    Text("Full").tag(ImmersionOption.full)
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .offset(y: -200)
        }
        .overlay(alignment: .topLeading) {
            FeePanelView(viewModel: viewModel)
                .offset(x: 50, y: 100)
        }
        .overlay(alignment: .topTrailing) {
            SearchPanelView(viewModel: viewModel)
                .offset(x: -50, y: 100)
        }
        .onAppear {
            print("🚀 BlockchainImmersiveView appeared - starting data load...")
            startEyeTracking()
            Task {
                print("📡 Starting data load task...")
                await viewModel.loadData()
                viewModel.connectToRealTimeData()
                print("🎯 Data load task completed. Blocks available: \(viewModel.blocks.count)")
                
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                await MainActor.run {
                    print("🎯 About to call createBlockEntities from MainActor")
                    print("🎯 Current blocks count: \(viewModel.blocks.count)")
                    print("🎯 Current rootEntity: \(rootEntity != nil ? "exists" : "nil")")
                    createBlockEntities()
                }
            }
        }
        .onReceive(viewModel.$mempoolStrata) { strata in
            self.mempoolStrata = strata
            if showMempoolView {
                createMempoolStrataVisualization()
            }
        }
        .onChange(of: immersionOption) { _, newValue in
            switch newValue {
            case .mixed: immersionStyle = .mixed
            case .full: immersionStyle = .full
            }
        }
        .onDisappear {
            stopEyeTracking()
        }
    }
    
    private func createPlaceholderBlocksData() -> [Block] {
        var blocks: [Block] = []
        for i in 0..<5 {
            let block = Block(
                id: "placeholder_\(i)",
                height: 800000 + i,
                timestamp: Int(Date().timeIntervalSince1970) - i * 600,
                txCount: 1000 + i * 100,
                size: 1000000 + i * 50000,
                weight: 4000000 + i * 200000,
                difficulty: 50000000000.0 + Double(i) * 1000000000.0
            )
            blocks.append(block)
        }
        return blocks.sorted { $0.height > $1.height }
    }
    
    private func createBlockEntities() {
        print("🔧 createBlockEntities called")
        print("🔧 Root entity exists: \(rootEntity != nil)")
        print("🔧 Blocks count: \(viewModel.blocks.count)")
        print("🔧 Block entities count: \(blockEntities.count)")
        
        guard let rootEntity = self.rootEntity else {
            print("❌ No root entity available for block creation")
            return
        }
        
        guard !viewModel.blocks.isEmpty else {
            print("❌ No blocks available - viewModel.blocks is empty")
            return
        }
        
        guard blockEntities.isEmpty else {
            print("⚠️ Block entities already exist - skipping creation")
            return
        }
        
        print("🎯 Creating \(viewModel.blocks.count) block entities...")
        print("🎯 Root entity children before: \(rootEntity.children.count)")
        
        // Remove loading text
        let _ = rootEntity.children.count // Track children count for debugging
        rootEntity.children.removeAll { child in
            let isLoadingText = child.name == "loading_text"
            if isLoadingText {
                print("🗑️ Removing loading text entity")
            }
            return isLoadingText
        }
        print("🎯 Root entity children after removing loading text: \(rootEntity.children.count)")
        
        // Add only the 3 most recent blocks for focused testing
        let blocksToDisplay = viewModel.blocks.sorted { $0.height > $1.height }.prefix(3)
        for (index, block) in blocksToDisplay.enumerated() {
            print("🎲 Creating block \(index + 1)/\(blocksToDisplay.count): #\(block.height)")
            let blockEntity = createBlockEntity(block: block, index: index)
            rootEntity.addChild(blockEntity)
            blockEntities[block.id] = blockEntity
        }
        
        print("✅ Block entities created successfully!")
        print("✅ Root entity children after: \(rootEntity.children.count)")
        print("✅ Block entities dictionary count: \(blockEntities.count)")
    }
    
    private func createBlockEntity(block: Block, index: Int) -> ModelEntity {
        print("🎲 createBlockEntity called for block #\(block.height) with \(block.txCount) transactions")
        
        // Standard block size - all blocks are the same size regardless of transaction count
        let blockSize: Float = 0.18 // Fixed size for all blocks
        
        print("🎲 Creating outer block entity...")
        // Create translucent outer block
        let blockEntity = ModelEntity(
            mesh: .generateBox(size: blockSize),
            materials: [createTranslucentMaterial(block: block, index: index)]
        )
        print("🎲 Outer block entity created successfully")
        
        print("🎲 Adding collision components...")
        // Add collision component for interaction
        blockEntity.collision = CollisionComponent(shapes: [.generateBox(size: SIMD3<Float>(blockSize, blockSize, blockSize))])
        blockEntity.components.set(InputTargetComponent())
        
        print("🎲 Setting position...")
        // Position blocks with proper spacing - first block directly in front of user
        let baseX = Float(index) * 0.35  // Much more spacing horizontally 
        let baseY = 1.6 + Float(index) * 0.03  // Start at eye level (1.6m), rise gradually
        let baseZ = -0.6 - Float(index) * 0.08  // Start closer to user, then recede
        
        blockEntity.position = SIMD3<Float>(baseX, baseY, baseZ)
        blockEntity.name = "block_\(index)"
        print("🎲 Position set to: \(blockEntity.position)")
        
        print("🎲 DEBUG: Block #\(block.height) has \(block.txCount) transactions")
        print("🎲 DEBUG: About to add transaction visualization...")
        do {
            // Add transaction visualization with density layers
            addOrderlyTransactionCubes(to: blockEntity, block: block, blockSize: blockSize, blockIndex: index)
            print("🎲 DEBUG: Transaction visualization added successfully for \(block.txCount) transactions")
        } catch {
            print("❌ DEBUG: Failed to add transaction visualization: \(error)")
            // Continue without transaction cubes rather than crash
        }
        
        print("🎲 Adding etched block info...")
        // Etch block information directly onto the top surface of the block
        addEtchedBlockInfo(to: blockEntity, block: block, blockSize: blockSize)
        print("🎲 Etched block info added")
        
        print("🎲 Block entity #\(block.height) completed successfully")
        return blockEntity
    }
    
    private func addOrderlyTransactionCubes(to blockEntity: ModelEntity, block: Block, blockSize: Float, blockIndex: Int) {
        print("🧊 addOrderlyTransactionCubes called for block with \(block.txCount) transactions")
        
        // Show actual transaction count for visual accuracy
        let txCubesToShow = block.txCount
        print("🧊 Will create \(txCubesToShow) individual transaction cubes")
        
        // Calculate available space inside the block (leave room for the block walls)
        let availableSpace = blockSize * 0.9 // Use 90% of block space for transactions
        
        // Calculate optimal 3D grid layout to fit all transactions
        // For better visual accuracy, calculate dimensions that best fit the transaction count
        let (gridX, gridY, gridZ) = calculateOptimalGridDimensions(
            transactionCount: txCubesToShow,
            availableSpace: availableSpace
        )
        
        // Calculate cube size that fits nicely in the grid
        let maxDimension = max(gridX, max(gridY, gridZ))
        let cubeSize = min(availableSpace / Float(maxDimension) * 0.85, 0.015) // Max size 0.015 for visibility
        let spacing = cubeSize * 1.05 // Minimal gap between cubes
        
        print("🧊 Grid layout: \(gridX)x\(gridY)x\(gridZ), cube size: \(cubeSize), spacing: \(spacing)")
        
        // Calculate starting position (bottom-left-back corner of available space)
        let startX = -availableSpace / 2 + cubeSize / 2
        let startY = -blockSize / 2 + cubeSize / 2 // Start from bottom of block
        let startZ = -availableSpace / 2 + cubeSize / 2
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Calculate transaction range once for all blocks
        let allTransactionCounts = viewModel.blocks.map { $0.txCount }
        let minTransactions = allTransactionCounts.min() ?? 1
        let maxTransactions = allTransactionCounts.max() ?? 4000
        
        print("🧊 DEBUG: All transaction counts: \(allTransactionCounts)")
        print("🧊 DEBUG: Min: \(minTransactions), Max: \(maxTransactions), Current: \(txCubesToShow)")
        
        // Create proportional transaction representation based on fullness
        createProportionalTransactionFill(
            blockEntity: blockEntity,
            transactionCount: txCubesToShow,
            blockSize: blockSize,
            minTransactions: minTransactions,
            maxTransactions: maxTransactions
        )
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let creationTime = endTime - startTime
        print("🧊 Individual cube creation completed in \(String(format: "%.3f", creationTime))s (\(txCubesToShow) transactions)")
        
        let transactionsPerSecond = Double(txCubesToShow) / creationTime
        print("🧊 Performance: \(String(format: "%.0f", transactionsPerSecond)) transactions/second")
    }
    
    private func createActualTransactionCubes(blockEntity: ModelEntity, transactionCount: Int, gridX: Int, gridY: Int, gridZ: Int, cubeSize: Float, spacing: Float, startPosition: SIMD3<Float>) {
        print("🚀 Creating \(transactionCount) individual transaction cubes")
        
        // Safety check for reasonable limits
        guard transactionCount > 0 && transactionCount < 100000 else {
            print("❌ Transaction count out of reasonable bounds: \(transactionCount)")
            return
        }
        
        guard cubeSize > 0.001 && cubeSize < 1.0 else {
            print("❌ Cube size out of reasonable bounds: \(cubeSize)")
            return
        }
        
        // Pre-generate cube mesh for efficiency
        guard let cubeMesh = try? MeshResource.generateBox(size: cubeSize) else {
            print("❌ Failed to generate cube mesh")
            return
        }
        
        // Create a container entity for all transaction cubes
        let transactionContainer = ModelEntity()
        transactionContainer.name = "transaction_cubes"
        
        var cubesCreated = 0
        let maxCubesToCreate = min(transactionCount, 200) // Much lower limit to prevent crashes
        
        print("🚀 Will create maximum \(maxCubesToCreate) cubes out of \(transactionCount) transactions")
        
        // Fill from bottom to top, layer by layer
        for y in 0..<gridY {
            if cubesCreated >= maxCubesToCreate { break }
            
            for z in 0..<gridZ {
                if cubesCreated >= maxCubesToCreate { break }
                
                for x in 0..<gridX {
                    if cubesCreated >= maxCubesToCreate { break }
                    if cubesCreated >= transactionCount { break }
                    
                    // Calculate position for this cube
                    let cubeX = startPosition.x + Float(x) * spacing
                    let cubeY = startPosition.y + Float(y) * spacing
                    let cubeZ = startPosition.z + Float(z) * spacing
                    
                    // Create transaction cube with error handling
                    do {
                        let txCube = ModelEntity(
                            mesh: cubeMesh,
                            materials: [createTransactionMaterial(index: cubesCreated)]
                        )
                        
                        txCube.position = SIMD3<Float>(cubeX, cubeY, cubeZ)
                        txCube.name = "tx_cube_\(cubesCreated)"
                        
                        transactionContainer.addChild(txCube)
                        cubesCreated += 1
                    } catch {
                        print("❌ Failed to create transaction cube \(cubesCreated): \(error)")
                        // Continue with remaining cubes instead of crashing
                        continue
                    }
                }
            }
        }
        
        // If we have more transactions than we can show individually, 
        // add a visual indicator for the remaining count
        if transactionCount > maxCubesToCreate {
            let remainingCount = transactionCount - maxCubesToCreate
            addRemainingTransactionIndicator(
                to: transactionContainer, 
                remainingCount: remainingCount, 
                position: SIMD3<Float>(0, startPosition.y + Float(gridY) * spacing + 0.02, 0)
            )
        }
        
        blockEntity.addChild(transactionContainer)
        print("🚀 Created \(cubesCreated) individual cubes (of \(transactionCount) total transactions)")
    }
    
    private func addRemainingTransactionIndicator(to container: ModelEntity, remainingCount: Int, position: SIMD3<Float>) {
        // Create a small indicator showing how many more transactions exist
        let indicatorText = "+\(remainingCount)"
        
        if let textMesh = try? MeshResource.generateText(
            indicatorText,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.008, weight: .medium)
        ) {
            let indicator = ModelEntity(
                mesh: textMesh,
                materials: [SimpleMaterial(color: .orange, isMetallic: false)]
            )
            
            indicator.position = position
            indicator.name = "remaining_tx_indicator"
            container.addChild(indicator)
        }
    }
    
    private func createProportionalTransactionFill(blockEntity: ModelEntity, transactionCount: Int, blockSize: Float, minTransactions: Int, maxTransactions: Int) {
        print("📊 Creating proportional fill for \(transactionCount) transactions")
        
        let availableSpace = blockSize * 0.9
        let container = ModelEntity()
        container.name = "proportional_transactions"
        
        // Calculate proportional fill based on provided data range
        let transactionRange = maxTransactions - minTransactions
        let normalizedCount = Float(transactionCount - minTransactions)
        let fillRatio = transactionRange > 0 ? min(1.0, normalizedCount / Float(transactionRange)) : 0.5
        
        print("📊 Transaction range: \(minTransactions)-\(maxTransactions), current: \(transactionCount)")
        print("📊 Fill ratio: \(String(format: "%.2f", fillRatio))")
        
        // Calculate how much of the block should be filled based on transaction count
        let maxFillHeight = availableSpace * 0.8 // Maximum height we'll fill
        let actualFillHeight = maxFillHeight * fillRatio
        
        // Standard cube size for consistent appearance - larger for better visibility
        let cubeSize: Float = 0.015
        let spacing: Float = cubeSize * 1.05 // Tighter spacing for cleaner grid
        
        // Calculate how many layers we should fill based on the fill ratio
        let maxLayers = Int(floor(maxFillHeight / spacing))
        let layersToFill = max(1, Int(floor(Float(maxLayers) * fillRatio)))
        
        // Calculate cubes per layer (fixed grid)
        let cubesPerRow = Int(floor(availableSpace / spacing))
        let cubesPerLayer = cubesPerRow * cubesPerRow
        
        print("📊 Will fill \(layersToFill) layers out of \(maxLayers) possible layers")
        print("📊 \(cubesPerLayer) cubes per layer, \(cubesPerRow)x\(cubesPerRow) grid")
        
        // Pre-generate cube mesh
        guard let cubeMesh = try? MeshResource.generateBox(size: cubeSize) else {
            print("❌ Failed to generate cube mesh for proportional fill")
            return
        }
        
        let startX = -availableSpace / 2 + cubeSize / 2
        let startY = -blockSize / 2 + cubeSize / 2
        let startZ = -availableSpace / 2 + cubeSize / 2
        
        var cubesCreated = 0
        let maxCubesToCreate = transactionCount // Show the actual transaction count
        
        // Fill layers from bottom up based on transaction count
        for layer in 0..<layersToFill {
            if cubesCreated >= maxCubesToCreate { break }
            
            for row in 0..<cubesPerRow {
                if cubesCreated >= maxCubesToCreate { break }
                
                for col in 0..<cubesPerRow {
                    if cubesCreated >= maxCubesToCreate { break }
                    
                    // Clean uniform grid positioning
                    let cubeX = startX + Float(col) * spacing
                    let cubeY = startY + Float(layer) * spacing
                    let cubeZ = startZ + Float(row) * spacing
                    
                    let txCube = ModelEntity(
                        mesh: cubeMesh,
                        materials: [createTransactionMaterial(index: cubesCreated)]
                    )
                    
                    txCube.position = SIMD3<Float>(cubeX, cubeY, cubeZ)
                    txCube.name = "proportional_tx_cube_\(cubesCreated)"
                    
                    container.addChild(txCube)
                    cubesCreated += 1
                }
            }
        }
        

        
        blockEntity.addChild(container)
        print("📊 Created proportional fill: \(cubesCreated) cubes in \(layersToFill) layers for \(transactionCount) transactions (fill ratio: \(String(format: "%.2f", fillRatio)))")
    }
    
    private func createHybridTransactionRepresentation(blockEntity: ModelEntity, transactionCount: Int, blockSize: Float) {
        print("🎯 Creating hybrid representation for \(transactionCount) transactions")
        
        let availableSpace = blockSize * 0.9
        let container = ModelEntity()
        container.name = "hybrid_transactions"
        
        // Show a few individual cubes at the bottom (sample representation)
        let sampleCubes = min(50, transactionCount)
        let cubeSize: Float = 0.012
        let spacing: Float = cubeSize * 1.1
        
        // Pre-generate cube mesh
        guard let cubeMesh = try? MeshResource.generateBox(size: cubeSize) else {
            print("❌ Failed to generate cube mesh for hybrid representation")
            return
        }
        
        // Create bottom layer of sample cubes
        let cubesPerRow = Int(floor(availableSpace / spacing))
        let rows = min(3, Int(ceil(Double(sampleCubes) / Double(cubesPerRow))))
        
        let startX = -availableSpace / 2 + cubeSize / 2
        let startY = -blockSize / 2 + cubeSize / 2
        let startZ = -availableSpace / 2 + cubeSize / 2
        
        var cubesCreated = 0
        
        for row in 0..<rows {
            if cubesCreated >= sampleCubes { break }
            
            for col in 0..<cubesPerRow {
                if cubesCreated >= sampleCubes { break }
                
                let cubeX = startX + Float(col) * spacing
                let cubeY = startY + Float(row) * spacing
                let cubeZ = startZ
                
                let txCube = ModelEntity(
                    mesh: cubeMesh,
                    materials: [createTransactionMaterial(index: cubesCreated)]
                )
                
                txCube.position = SIMD3<Float>(cubeX, cubeY, cubeZ)
                txCube.name = "sample_tx_cube_\(cubesCreated)"
                container.addChild(txCube)
                cubesCreated += 1
            }
        }
        
        // Add text indicator showing total count
        let totalText = "\(transactionCount) TXs"
        if let textMesh = try? MeshResource.generateText(
            totalText,
            extrusionDepth: 0.003,
            font: .systemFont(ofSize: 0.015, weight: .medium)
        ) {
            let textEntity = ModelEntity(
                mesh: textMesh,
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            
            textEntity.position = SIMD3<Float>(0, startY + Float(rows) * spacing + 0.03, 0)
            textEntity.name = "tx_count_display"
            container.addChild(textEntity)
        }
        
        blockEntity.addChild(container)
        print("🎯 Created hybrid representation with \(cubesCreated) sample cubes for \(transactionCount) total transactions")
    }
    
    private func calculateOptimalGridDimensions(transactionCount: Int, availableSpace: Float) -> (Int, Int, Int) {
        // For small transaction counts, use simple cube root approach
        if transactionCount <= 64 {
            let cubeRoot = Int(ceil(pow(Double(transactionCount), 1.0/3.0)))
            return (cubeRoot, cubeRoot, cubeRoot)
        }
        
        // For larger counts, optimize the grid to fill from bottom up naturally
        // Calculate maximum cubes that can fit in each dimension with reasonable cube size
        let minCubeSize: Float = 0.008 // Minimum visible cube size
        let maxCubesPerDimension = Int(floor(availableSpace / (minCubeSize * 1.1))) // Include spacing
        
        // Start with cube root as baseline, then adjust for better packing
        let cubeRoot = pow(Double(transactionCount), 1.0/3.0)
        var gridX = min(maxCubesPerDimension, max(1, Int(ceil(cubeRoot))))
        var gridZ = min(maxCubesPerDimension, max(1, Int(ceil(cubeRoot))))
        
        // Calculate required Y dimension to fit all transactions
        let baseArea = gridX * gridZ
        var gridY = min(maxCubesPerDimension, max(1, Int(ceil(Double(transactionCount) / Double(baseArea)))))
        
        // Adjust dimensions to better utilize space while maintaining visual balance
        while gridX * gridY * gridZ < transactionCount && gridY < maxCubesPerDimension {
            gridY += 1
        }
        
        // If still not enough space, expand X and Z dimensions
        while gridX * gridY * gridZ < transactionCount && (gridX < maxCubesPerDimension || gridZ < maxCubesPerDimension) {
            if gridX <= gridZ && gridX < maxCubesPerDimension {
                gridX += 1
            } else if gridZ < maxCubesPerDimension {
                gridZ += 1
            } else {
                break
            }
        }
        
        print("🧊 Calculated grid for \(transactionCount) transactions: \(gridX)x\(gridY)x\(gridZ) = \(gridX * gridY * gridZ) slots")
        
        return (gridX, gridY, gridZ)
    }
    

    
    private func addEtchedBlockInfo(to blockEntity: ModelEntity, block: Block, blockSize: Float) {
        let etchedText = createEtchedBlockInfoText(block: block)
        
        for (index, textElement) in etchedText.enumerated() {
            let fontWeight: UIFont.Weight = index == 0 ? .medium : .regular // Clean Apple-style weights
            let extrusionDepth: Float = index == 0 ? 0.002 : 0.001 // Minimal recessed etching - part of the block
            let textEntity = ModelEntity(
                mesh: .generateText(textElement.text, extrusionDepth: extrusionDepth, font: .systemFont(ofSize: CGFloat(textElement.fontSize), weight: fontWeight)),
                materials: [createLaserEtchedTextMaterial(for: textElement.color, isTitle: index == 0)]
            )
            
            // Rotate text to lie flat on top surface (Apple-style etched look)
            textEntity.transform.rotation = simd_quatf(angle: -.pi/2, axis: SIMD3<Float>(1, 0, 0))
            
            // Position text elements minimally recessed INTO the top surface of the block
            let lineSpacing: Float = 0.015 // Clean, minimal spacing
            let surfaceOffset: Float = blockSize / 2 - 0.001 // Slightly RECESSED into the surface
            
            // Position in upper left corner of the block surface with clean hierarchy
            let yOffset: Float
            let xOffset: Float
            
            if index == 0 {
                // Block number in TRUE upper left corner (moved higher and more left)
                yOffset = blockSize * 0.46 // Higher up on the block
                xOffset = -blockSize * 0.46 // Further left on the block
            } else {
                // Details below block number with minimal, clean spacing
                yOffset = blockSize * 0.32 - Float(index) * lineSpacing // Below with hierarchy
                xOffset = -blockSize * 0.32 // Same left alignment
            }
            
            textEntity.position = SIMD3<Float>(xOffset, surfaceOffset, yOffset)
            textEntity.name = "etched_text_\(index)"
            
            blockEntity.addChild(textEntity)
        }
    }
    
    private func createEtchedBlockInfoText(block: Block) -> [ScientificTextElement] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm" // Shorter, more compact format
        
        let blockDate = dateFormatter.string(from: block.blockTime)
        
        // Format numbers with appropriate units for better readability
        let sizeKB = Double(block.size) / 1024.0
        let weightKWU = Double(block.weight) / 1000.0
        
        // Show transaction count - first 5 blocks show full count, others may be limited
        // Note: We don't have blockIndex here, so we'll assume most blocks show some limitation
        // The actual cube creation will handle the priority logic
        let backgroundLimit = 200
        let isLikelyLimited = block.txCount > backgroundLimit
        let txDisplayText = isLikelyLimited ? "\(block.txCount) TXs" : "\(block.txCount) TXs"
        
        return [
            ScientificTextElement(text: "\(block.height)", fontSize: 0.028, color: .white), // Larger block number
            ScientificTextElement(text: txDisplayText, fontSize: 0.012, color: .gray), // Smaller details with indicator
            ScientificTextElement(text: blockDate, fontSize: 0.010, color: .gray), // Even smaller
            ScientificTextElement(text: "\(String(format: "%.1f", sizeKB))KB", fontSize: 0.010, color: .gray), // Consistent
            ScientificTextElement(text: "\(String(format: "%.1f", weightKWU))KWU", fontSize: 0.010, color: .gray) // Consistent
        ]
    }
    
    private func createLaserEtchedTextMaterial(for color: UIColor, isTitle: Bool) -> SimpleMaterial {
        // Create realistic laser-etched appearance with clear contrast
        let etchedColor: UIColor
        
        if isTitle {
            // Block number: Brighter whitish gray etching
            etchedColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0) // More whitish gray
        } else {
            // Block details: Apple-style darker etched gray
            etchedColor = UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1.0) // Darker professional gray
        }
        
        return SimpleMaterial(color: etchedColor, isMetallic: false)
    }
    
    private func createTranslucentMaterial(block: Block, index: Int) -> SimpleMaterial {
        // Create crystal clear glass material for optimal visibility of contents
        if selectedBlockIndex == index || lookedAtBlockIndex == index {
            // Selected or looked at block - bright cyan glow with crystal clear transparency
            var selectedMaterial = SimpleMaterial()
            selectedMaterial.color = PhysicallyBasedMaterial.BaseColor(tint: .cyan)
            selectedMaterial.roughness = .init(floatLiteral: 0.1) // Very smooth for glass effect
            selectedMaterial.metallic = .init(floatLiteral: 0.0) // Non-metallic for transparency
            // selectedMaterial.faceCulling = .none // faceCulling unavailable in visionOS
            return selectedMaterial
        } else {
            // Crystal clear glass material - truly transparent for bright content visibility
            var clearMaterial = SimpleMaterial()
            // Use pure white with very low alpha for maximum transparency
            clearMaterial.color = PhysicallyBasedMaterial.BaseColor(tint: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1))
            clearMaterial.roughness = .init(floatLiteral: 0.05) // Very smooth for crystal clear effect
            clearMaterial.metallic = .init(floatLiteral: 0.0) // Non-metallic for transparency
            // clearMaterial.faceCulling = .none // faceCulling unavailable in visionOS
            return clearMaterial
        }
    }
    
    private func createTransactionMaterial(index: Int) -> SimpleMaterial {
        // Create bright, vibrant transaction cube materials for crystal clear visibility
        // Use bright, saturated colors that stand out against the clear block background
        let colors: [UIColor] = [
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),  // Bright blue
            UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0),  // Bright cyan
            UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),  // Light blue
            UIColor(red: 0.0, green: 1.0, blue: 0.6, alpha: 1.0),  // Bright green-blue
            UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),  // Bright green
            UIColor(red: 0.6, green: 0.6, blue: 1.0, alpha: 1.0),  // Bright purple-blue
            UIColor(red: 0.0, green: 1.0, blue: 0.8, alpha: 1.0),  // Bright turquoise
            UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)   // Bright indigo
        ]
        
        var material = SimpleMaterial()
        material.color = PhysicallyBasedMaterial.BaseColor(tint: colors[index % colors.count])
        material.roughness = .init(floatLiteral: 0.2) // Smoother for better light reflection
        material.metallic = .init(floatLiteral: 0.0) // Non-metallic for stability
        
        // Ensure both sides of faces are rendered to prevent culling issues
        // material.faceCulling = .none // faceCulling unavailable in visionOS
        
        return material
    }
    
    private func handleBlockSelection(at location: CGPoint) {
        print("🎯 Tap detected at: \(location)")
        
        // Only select a block if the user is looking at it
        if let lookedAtBlockIndex = lookedAtBlockIndex,
           let _ = viewModel.blocks.indices.contains(lookedAtBlockIndex) ? viewModel.blocks[lookedAtBlockIndex] : nil {
            selectedBlockIndex = lookedAtBlockIndex
            print("🎯 Selected block: \(lookedAtBlockIndex)")
        } else {
            print("👁️ Not looking at a block, no selection made.")
        }
    }
    
    private func handleFingerTap() {
        print("👋 Finger tap detected")
        
        // Only select a block if the user is looking at it
        if let lookedAtBlockIndex = lookedAtBlockIndex,
           let _ = viewModel.blocks.indices.contains(lookedAtBlockIndex) ? viewModel.blocks[lookedAtBlockIndex] : nil {
            selectedBlockIndex = lookedAtBlockIndex
            print("🎯 Selected block: \(lookedAtBlockIndex)")
        } else {
            print("👁️ Not looking at a block, no selection made.")
        }
    }
    
    private func startEyeTracking() {
        Task {
            do {
                // Create ARKit session for head tracking (which we'll use for gaze approximation)
                let session = ARKitSession()
                self.arSession = session
                
                // Start world tracking to get head position and orientation
                try await session.run([worldTrackingProvider])
                print("👁️ Head tracking started successfully for gaze approximation")
                
                // Start the gaze tracking update loop
                startGazeTrackingUpdates()
                
            } catch {
                print("👁️ Failed to start head tracking: \(error)")
                // Fallback to simulated eye tracking if real tracking fails
                startSimulatedEyeTracking()
            }
        }
    }
    
    private func startGazeTrackingUpdates() {
        eyeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                await updateGazeFromHeadTracking()
            }
        }
    }
    
    private func updateGazeFromHeadTracking() async {
        // Use head tracking as a proxy for gaze direction (center of view)
        // This is more reliable than true eye tracking and still provides good UX
        let gazeDirection = SIMD3<Float>(0, 0, -1) // Looking forward from head
        
        // Perform ray casting to find which block the user is looking at
        if let lookedAtBlock = performRayCastingForGaze(gazeDirection: gazeDirection) {
            if lookedAtBlock != lookedAtBlockIndex {
                lookedAtBlockIndex = lookedAtBlock
                print("👁️ Looking at block: \(lookedAtBlock)")
            }
        } else {
            if lookedAtBlockIndex != nil {
                lookedAtBlockIndex = nil
                print("👁️ Not looking at any block")
            }
        }
    }
    
    private func startSimulatedEyeTracking() {
        print("👁️ Using simulated eye tracking as fallback")
        eyeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let centerPoint = CGPoint(x: 0.5, y: 0.5)
            let closestBlockIndex = findClosestBlockToPoint(centerPoint)
            
            if closestBlockIndex != lookedAtBlockIndex && closestBlockIndex != nil {
                lookedAtBlockIndex = closestBlockIndex
                print("👁️ Simulated: Looking at block: \(closestBlockIndex ?? -1)")
            }
        }
    }
    
    private func performRayCastingForGaze(gazeDirection: SIMD3<Float>) -> Int? {
        guard rootEntity != nil else { return nil }
        
        // Create a ray from the user's eye position in the gaze direction
        let rayOrigin = SIMD3<Float>(0, 1.6, 0) // Approximate eye height in meters
        let rayDirection = normalize(gazeDirection)
        
        // Check intersection with each block entity
        for (blockId, blockEntity) in blockEntities {
            if rayIntersectsBlock(rayOrigin: rayOrigin, 
                                rayDirection: rayDirection, 
                                blockEntity: blockEntity) {
                // Find the index of this block
                let blocksToCheck = viewModel.blocks.sorted { $0.height > $1.height }
                
                for (index, block) in blocksToCheck.enumerated() {
                    if block.id == blockId {
                        return index
                    }
                }
            }
        }
        
        return nil
    }
    
    private func rayIntersectsBlock(rayOrigin: SIMD3<Float>, rayDirection: SIMD3<Float>, blockEntity: ModelEntity) -> Bool {
        // Get the block's world position (including chain offset)
        let blockWorldPosition = blockEntity.position + (rootEntity?.transform.translation ?? SIMD3<Float>(0, 0, 0))
        
        // Use standardized block size for collision detection
        let blockSize: Float = 0.18 // Standard size from createBlockEntity
        let halfSize = blockSize / 2
        
        // Simple AABB (Axis-Aligned Bounding Box) intersection test
        let blockMin = blockWorldPosition - SIMD3<Float>(halfSize, halfSize, halfSize)
        let blockMax = blockWorldPosition + SIMD3<Float>(halfSize, halfSize, halfSize)
        
        return rayIntersectsAABB(rayOrigin: rayOrigin, rayDirection: rayDirection, aabbMin: blockMin, aabbMax: blockMax)
    }
    
    private func rayIntersectsAABB(rayOrigin: SIMD3<Float>, rayDirection: SIMD3<Float>, aabbMin: SIMD3<Float>, aabbMax: SIMD3<Float>) -> Bool {
        let invDir = SIMD3<Float>(1.0 / rayDirection.x, 1.0 / rayDirection.y, 1.0 / rayDirection.z)
        
        let t1 = (aabbMin - rayOrigin) * invDir
        let t2 = (aabbMax - rayOrigin) * invDir
        
        let tMin = min(t1, t2)
        let tMax = max(t1, t2)
        
        let tNear = max(max(tMin.x, tMin.y), tMin.z)
        let tFar = min(min(tMax.x, tMax.y), tMax.z)
        
        return tNear <= tFar && tFar >= 0
    }
    
    private func findClosestBlockToPoint(_ point: CGPoint) -> Int? {
        // Fallback simulation for when real eye tracking is not available
        let blocksToCheck = viewModel.blocks.isEmpty ? 5 : viewModel.blocks.count
        
        // Cycle through blocks slowly for simulation
        let currentTime = Date().timeIntervalSince1970
        let blockCycleTime = 2.0 // 2 seconds per block
        let currentBlockIndex = Int(currentTime / blockCycleTime) % blocksToCheck
        
        return currentBlockIndex
    }
    
    private func stopEyeTracking() {
        eyeTrackingTimer?.invalidate()
        eyeTrackingTimer = nil
        
        // Stop ARKit session
        arSession?.stop()
        arSession = nil
        
        print("👁️ Eye tracking stopped")
    }

    // MARK: - Precision helpers to reduce micro jitter at rest
    private func roundToStep(_ value: Float, step: Float) -> Float {
        return (value / step).rounded() * step
    }
    private func roundVector(_ v: SIMD3<Float>, step: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            roundToStep(v.x, step: step),
            roundToStep(v.y, step: step),
            roundToStep(v.z, step: step)
        )
    }
    
    private func handleChainDrag(translation: CGSize) {
        guard let rootEntity = self.rootEntity else { return }
        // If we were decelerating, stop immediately when user interacts
        stopDeceleration()
        
        // Calculate delta from last translation (since DragGesture gives cumulative translation)
        let deltaX = translation.width - lastDragTranslation.width
        let deltaY = translation.height - lastDragTranslation.height
        lastDragTranslation = translation
        
        // Convert 2D drag to 3D chain movement with improved sensitivity
        let dragScale: Float = 0.0016 // Reduced sensitivity for finer control
        
        // Intuitive mapping:
        // Drag = X/Y (left/right, up/down). Z is controlled by pinch for clarity.
        chainOffset.x += Float(deltaX) * dragScale // Left/right movement
        chainOffset.y -= Float(deltaY) * dragScale // Up/down movement (inverted for natural feel)
        print("🖐️ Drag: delta(\(deltaX), \(deltaY)) -> position\(chainOffset)")
        
        // Apply position immediately to rootEntity for real-time movement
        rootEntity.transform.translation = chainOffset
        
        isInteracting = true
    }
    
    private func handleChainDragEnd(velocity: CGSize) {
        // Reset drag tracking
        lastDragTranslation = CGSize.zero
        
        // Start momentum-based deceleration using gesture velocity (points/sec → meters/sec scale)
        let velocityScale: Float = 0.0005
        chainVelocity.x = Float(velocity.width) * velocityScale
        chainVelocity.y = -Float(velocity.height) * velocityScale
        chainVelocity.z = 0 // Z unaffected by drag; pinch controls Z
        startDeceleration()
    }
    
    private func handleDepthControl(magnification: CGFloat) {
        guard let rootEntity = self.rootEntity else { return }
        // Stop any ongoing deceleration when user pinches
        stopDeceleration()
        
        // Convert magnification to depth delta (closer/further), accumulate so push/pull can continue
        // More intuitive: pinch in = pull closer (negative Z), pinch out = push away (positive Z)
        let delta = Float(lastMagnificationValue - magnification) * 1.5 // higher sensitivity, accumulate
        lastMagnificationValue = magnification
        
        // Apply delta to Z and capture per-frame delta for momentum later
        let previousZ = chainOffset.z
        chainOffset.z += delta
        let now = Date().timeIntervalSinceReferenceDate
        lastDepthDeltaZ = chainOffset.z - previousZ
        lastDepthUpdateTime = now
        
        // Apply position immediately to rootEntity for real-time movement
        rootEntity.transform.translation = chainOffset
        
        isInteracting = true
        print("🤏 Pinch-to-move: magnification \(magnification) -> depth \(chainOffset.z)")
    }
    
    private func handleDepthControlEnd() {
        // Store the final depth position as the new base
        baseChainDistance = chainOffset.z
        
        // Reset magnification baseline for next pinch
        lastMagnificationValue = 1.0
        
        // Start deceleration on Z using last observed delta and time
        let now = Date().timeIntervalSinceReferenceDate
        let dt = max(0.008, now - lastDepthUpdateTime)
        var vz = lastDepthDeltaZ / Float(dt) * 1.5 // gain for longer glide
        // Clamp to avoid crazy spikes
        let maxVz: Float = 0.8
        if vz > maxVz { vz = maxVz }
        if vz < -maxVz { vz = -maxVz }
        chainVelocity.z = vz
        startDeceleration()
    }

    // MARK: - Momentum Deceleration
    private func startDeceleration() {
        decelerationTimer?.invalidate()
        isInteracting = true
        
        decelerationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/120.0, repeats: true) { _ in
            guard let rootEntity = self.rootEntity else { return }
            let dt: Float = 1.0/120.0
            
            chainOffset += chainVelocity * dt
            rootEntity.transform.translation = chainOffset
            
            let friction: Float = 0.992
            chainVelocity *= friction
            
            let speed = abs(chainVelocity.x) + abs(chainVelocity.y) + abs(chainVelocity.z)
            if speed < 0.000001 {
                let snapped = self.roundVector(self.chainOffset, step: 0.0001)
                self.chainOffset = snapped
                rootEntity.transform.translation = snapped
                self.decelerationTimer?.invalidate()
                self.decelerationTimer = nil
                self.isInteracting = false
                self.baseChainDistance = self.chainOffset.z
            }
        }
    }

    private func stopDeceleration() {
        decelerationTimer?.invalidate()
        decelerationTimer = nil
        chainVelocity = SIMD3<Float>(0, 0, 0)
    }
    
    private func createMempoolStrataVisualization() {
        guard let rootEntity = self.rootEntity else { return }
        
        mempoolEntity?.removeFromParent()
        
        let mempoolContainer = Entity()
        mempoolContainer.name = "mempool_strata"
        
        for (index, stratum) in mempoolStrata.enumerated() {
            let stratumEntity = createStratumEntity(stratum: stratum, index: index)
            mempoolContainer.addChild(stratumEntity)
        }
        
        mempoolContainer.position = SIMD3<Float>(-1.0, 0, -0.5)
        rootEntity.addChild(mempoolContainer)
        self.mempoolEntity = mempoolContainer
    }
    
    private func createStratumEntity(stratum: MempoolStrata, index: Int) -> ModelEntity {
        let height = max(0.05, stratum.visualHeight)
        let width: Float = 0.3
        let depth: Float = 0.3
        
        let mesh = MeshResource.generateBox(size: SIMD3<Float>(width, height, depth))
        var material = SimpleMaterial()
        
        switch stratum.color {
        case .red: material.baseColor = .color(.red)
        case .orange: material.baseColor = .color(.orange)  
        case .yellow: material.baseColor = .color(.yellow)
        case .green: material.baseColor = .color(.green)
        }
        
        material.roughness = 0.3
        material.metallic = 0.1
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        let yOffset = Float(index) * 0.1 + height / 2
        entity.position = SIMD3<Float>(0, yOffset, 0)
        entity.name = "stratum_\(index)"
        
        entity.collision = CollisionComponent(shapes: [.generateBox(size: SIMD3<Float>(width, height, depth))])
        entity.components.set(InputTargetComponent())
        
        return entity
    }

}

// Helper struct for scientific text elements
struct ScientificTextElement {
    let text: String
    let fontSize: Float
    let color: UIColor
}



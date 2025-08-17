import SwiftUI
import RealityKit

struct BlockchainView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading blockchain...")
            } else {
                // Debug info
                Text("Loaded \(viewModel.blocks.count) blocks")
                    .font(.caption)
                    .padding()
                
                // Show first few block heights for debugging
                if !viewModel.blocks.isEmpty {
                    Text("Block heights: \(viewModel.blocks.prefix(5).map { $0.height }.description)")
                        .font(.caption)
                        .padding()
                }
                
                RealityView { content in
                    // Simple 3D scene
                    let rootEntity = Entity()
                    
                    print("🎲 Creating \(viewModel.blocks.count) block entities")
                    
                    // Add blocks as simple cubes
                    for (index, block) in viewModel.blocks.prefix(20).enumerated() {
                        let mesh = MeshResource.generateBox(size: 0.1)
                        var material = SimpleMaterial()
                        
                        // Use block height to determine color for now
                        let hue = Float(block.height % 10) / 10.0
                        material.baseColor = .init(_colorLiteralRed: Float(hue), 
                                                 green: Float(1.0 - hue), 
                                                 blue: Float(0.5), 
                                                 alpha: Float(1.0))
                        
                        let blockEntity = ModelEntity(mesh: mesh, materials: [material])
                        blockEntity.position = SIMD3<Float>(Float(index) * 0.2, 0, 0)
                        blockEntity.name = "block_\(block.height)"
                        
                        print("🎲 Added block \(block.height) at position \(blockEntity.position)")
                        
                        rootEntity.addChild(blockEntity)
                    }
                    
                    content.add(rootEntity)
                } update: { content in
                    // Update scene if needed
                }
                .gesture(
                    TapGesture()
                        .targetedToAnyEntity()
                        .onEnded { value in
                            let entity = value.entity
                            if let blockHeight = extractBlockHeight(from: entity.name) {
                                if let block = viewModel.blocks.first(where: { $0.height == blockHeight }) {
                                    viewModel.selectBlock(block)
                                }
                            }
                        }
                )
            }
        }
        .navigationTitle("Blockchain")
    }
    
    private func colorForFeeRate(_ feeRate: Double) -> UIColor {
        if feeRate > 100 { return .red }
        else if feeRate > 50 { return .orange }
        else if feeRate > 20 { return .yellow }
        else { return .green }
    }
    
    private func extractBlockHeight(from name: String) -> Int? {
        let components = name.split(separator: "_")
        return components.last.flatMap { Int($0) }
    }
}
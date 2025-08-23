import SwiftUI
import RealityKit

struct TransactionImmersiveView: View {
    let transaction: Transaction
    @State private var rootEntity: Entity?
    
    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "transaction_detail_root"
            
            createTransactionVisualization(root: root)
            
            content.add(root)
            self.rootEntity = root
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
    }
    
    private func createTransactionVisualization(root: Entity) {
        for (index, input) in transaction.vin.enumerated() {
            let inputEntity = createInputEntity(input: input, index: index)
            root.addChild(inputEntity)
        }
        
        for (index, output) in transaction.vout.enumerated() {
            let outputEntity = createOutputEntity(output: output, index: index)
            root.addChild(outputEntity)
        }
        
        createTransactionFlow(root: root)
    }
    
    private func createInputEntity(input: Transaction.TransactionInput, index: Int) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(-0.5, Float(index) * 0.15, 0)
        entity.name = "input_\(index)"
        
        return entity
    }
    
    private func createOutputEntity(output: Transaction.TransactionOutput, index: Int) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0.5, Float(index) * 0.15, 0)
        entity.name = "output_\(index)"
        
        return entity
    }
    
    private func createTransactionFlow(root: Entity) {
        
    }
    
    private func handleEntityTap(_ entity: Entity) {
        
    }
}

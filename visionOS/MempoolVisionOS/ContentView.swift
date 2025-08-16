import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var viewModel = BlockchainViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with controls and navigation
            SidebarView(viewModel: viewModel)
        } detail: {
            // Main 3D blockchain visualization
            Blockchain3DView(viewModel: viewModel)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct SidebarView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        List {
            Section("Navigation") {
                Button("Go to Latest Block") {
                    viewModel.goToLatestBlock()
                }
                
                Button("Show Mempool") {
                    viewModel.showMempool()
                }
                
                Button("Fee Market View") {
                    viewModel.showFeeMarket()
                }
            }
            
            Section("Block Details") {
                if let selectedBlock = viewModel.selectedBlock {
                    VStack(alignment: .leading) {
                        Text("Block #\(selectedBlock.height)")
                            .font(.headline)
                        Text("Hash: \(selectedBlock.hash.prefix(16))...")
                            .font(.caption)
                        Text("Transactions: \(selectedBlock.txCount)")
                            .font(.caption)
                        Text("Size: \(selectedBlock.size) bytes")
                            .font(.caption)
                    }
                } else {
                    Text("Select a block to view details")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Network Stats") {
                VStack(alignment: .leading) {
                    Text("Current Height: \(viewModel.currentHeight)")
                    Text("Mempool Size: \(viewModel.mempoolSize)")
                    Text("Average Fee: \(viewModel.averageFee, specifier: "%.2f") sat/vB")
                }
            }
        }
        .navigationTitle("Mempool VisionOS")
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var viewModel: BlockchainViewModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var showingImmersive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView()
                
                HStack(spacing: 20) {
                    VStack(spacing: 16) {
                        ConfigurationPanelView(viewModel: viewModel)
                        SearchPanelView(viewModel: viewModel)
                    }
                    
                    VStack(spacing: 16) {
                        FeePanelView(viewModel: viewModel)
                        StatusPanelView(viewModel: viewModel)
                    }
                }
                
                Spacer()
                
                Button(action: launchImmersiveSpace) {
                    HStack {
                        Image(systemName: "visionpro")
                        Text("Enter Immersive Blockchain")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue.gradient)
                    .cornerRadius(12)
                }
                .disabled(showingImmersive)
            }
            .padding()
            .navigationTitle("Spatial Mempool")
        }
        .onAppear {
            Task {
                await viewModel.loadData()
                viewModel.connectToRealTimeData()
            }
        }
    }
    
    private func launchImmersiveSpace() {
        Task {
            showingImmersive = true
            await openImmersiveSpace(id: "BlockchainSpace")
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            Text("Spatial Mempool")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Immersive Bitcoin Blockchain Explorer")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
}

struct StatusPanelView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Status")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(viewModel.isConnectedToWebSocket ? .green : .red)
                    .frame(width: 12, height: 12)
                Text(viewModel.isConnectedToWebSocket ? "Connected" : "Disconnected")
                    .font(.subheadline)
            }
            
            if !viewModel.blocks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest Block: #\(viewModel.blocks.first?.height ?? 0)")
                        .font(.subheadline)
                    Text("Blocks Loaded: \(viewModel.blocks.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.isLoading {
                ProgressView("Loading blockchain data...")
                    .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

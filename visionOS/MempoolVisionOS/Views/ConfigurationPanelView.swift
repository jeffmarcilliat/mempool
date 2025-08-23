import SwiftUI

struct ConfigurationPanelView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    @State private var isUsingSelfHosted = false
    @State private var selfHostedURL = "http://localhost:8999"
    @State private var isTestingConnection = false
    @State private var connectionStatus: ConnectionStatus = .unknown
    
    enum ConnectionStatus {
        case unknown, testing, connected, failed
        
        var color: Color {
            switch self {
            case .unknown: return .gray
            case .testing: return .orange
            case .connected: return .green
            case .failed: return .red
            }
        }
        
        var text: String {
            switch self {
            case .unknown: return "Unknown"
            case .testing: return "Testing..."
            case .connected: return "Connected"
            case .failed: return "Failed"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Use Self-Hosted Backend", isOn: $isUsingSelfHosted)
                    .onChange(of: isUsingSelfHosted) { _, newValue in
                        updateConfiguration(useSelfHosted: newValue)
                    }
                
                if isUsingSelfHosted {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Backend URL", text: $selfHostedURL)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                testConnection()
                            }
                        
                        HStack {
                            Button("Test Connection") {
                                testConnection()
                            }
                            .buttonStyle(.bordered)
                            .disabled(isTestingConnection)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(connectionStatus.color)
                                    .frame(width: 8, height: 8)
                                Text(connectionStatus.text)
                                    .font(.caption)
                            }
                        }
                        
                        Text("Make sure your self-hosted mempool backend is running on the specified URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            loadConfiguration()
        }
    }
    
    private func loadConfiguration() {
        isUsingSelfHosted = UserDefaults.standard.bool(forKey: "isUsingSelfHosted")
        selfHostedURL = UserDefaults.standard.string(forKey: "selfHostedURL") ?? "http://localhost:8999"
        
        let mempoolService = viewModel.mempoolServiceInstance
        mempoolService.isUsingSelfHosted = isUsingSelfHosted
        mempoolService.selfHostedURL = selfHostedURL
    }
    
    private func updateConfiguration(useSelfHosted: Bool) {
        UserDefaults.standard.set(useSelfHosted, forKey: "isUsingSelfHosted")
        UserDefaults.standard.set(selfHostedURL, forKey: "selfHostedURL")
        
        let mempoolService = viewModel.mempoolServiceInstance
        mempoolService.isUsingSelfHosted = useSelfHosted
        mempoolService.selfHostedURL = selfHostedURL
        
        Task {
            await mempoolService.reconnectWithNewConfiguration()
            await viewModel.loadData()
        }
    }
    
    private func testConnection() {
        guard !selfHostedURL.isEmpty else { return }
        
        isTestingConnection = true
        connectionStatus = .testing
        
        Task {
            let isConnected = await testBackendConnection(url: selfHostedURL)
            
            await MainActor.run {
                connectionStatus = isConnected ? .connected : .failed
                isTestingConnection = false
            }
        }
    }
    
    private func testBackendConnection(url: String) async -> Bool {
        guard let testURL = URL(string: "\(url)/api/v1/blocks") else { return false }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: testURL)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Connection test failed: \(error)")
        }
        
        return false
    }
}

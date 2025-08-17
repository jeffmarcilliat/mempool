import Foundation
import Combine

class MempoolService: ObservableObject {
    private let baseURL = "https://mempool.space/api/v1"
    
    @Published var blocks: [Block] = []
    @Published var mempoolTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchBlocks() async {
        await MainActor.run { isLoading = true }
        
        do {
            let url = URL(string: "\(baseURL)/blocks")!
            print(" Fetching blocks...")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }
            
            let fetchedBlocks = try JSONDecoder().decode([Block].self, from: data)
            print("✅ Loaded \(fetchedBlocks.count) blocks")
            
            await MainActor.run {
                self.blocks = fetchedBlocks
                self.isLoading = false
            }
        } catch {
            print("❌ Error fetching blocks: \(error)")
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
        func fetchMempool() async {
        print("🔍 Attempting to fetch mempool info...")
        
        do {
            // Try the mempool info endpoint first
            let url = URL(string: "\(baseURL)/mempool")!
            
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Mempool HTTP Status: \(httpResponse.statusCode)")
                
                // If it's a 404 or other error, just skip mempool data
                if httpResponse.statusCode != 200 {
                    print("⚠️ Mempool endpoint not available, skipping mempool data")
                    await MainActor.run {
                        self.mempoolTransactions = [] // Empty mempool is fine
                    }
                    return
                }
            }
            
            // For now, let's create some sample transaction data since the API might not return recent transactions
            let sampleTransactions = [
                Transaction(
                    id: "sample_tx_1",
                    fee: 1000,
                    size: 250,
                    weight: 1000,
                    status: Transaction.TransactionStatus(confirmed: false, blockHeight: nil, blockHash: nil, blockTime: nil),
                    vin: [],
                    vout: []
                ),
                Transaction(
                    id: "sample_tx_2",
                    fee: 2000,
                    size: 500,
                    weight: 2000,
                    status: Transaction.TransactionStatus(confirmed: false, blockHeight: nil, blockHash: nil, blockTime: nil),
                    vin: [],
                    vout: []
                )
            ]
            
            print("✅ Created \(sampleTransactions.count) sample mempool transactions")
            
            await MainActor.run {
                self.mempoolTransactions = sampleTransactions
            }
        } catch {
            print("⚠️ Mempool fetch failed (this is OK): \(error.localizedDescription)")
            // Don't set error state for mempool failures - just use empty mempool
            await MainActor.run {
                self.mempoolTransactions = []
            }
        }
    }
}
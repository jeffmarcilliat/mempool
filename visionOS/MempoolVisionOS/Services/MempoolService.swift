import Foundation
import Combine

class MempoolService: ObservableObject {
    private let baseURL = "https://mempool.space/api"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties for real-time updates
    @Published var currentHeight: Int = 0
    @Published var mempoolSize: Int = 0
    @Published var averageFee: Double = 0.0
    @Published var mempoolTransactions: [Transaction] = []
    @Published var recentBlocks: [Block] = []
    
    init() {
        startPeriodicUpdates()
    }
    
    // MARK: - Block Methods
    
    func fetchBlocks(fromHeight: Int? = nil, limit: Int = 15) -> AnyPublisher<[Block], Error> {
        var urlString = "\(baseURL)/v1/blocks"
        if let fromHeight = fromHeight {
            urlString += "/\(fromHeight)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Block].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchBlock(hash: String) -> AnyPublisher<Block, Error> {
        let urlString = "\(baseURL)/v1/block/\(hash)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Block.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchBlockTransactions(hash: String, startIndex: Int = 0) -> AnyPublisher<[Transaction], Error> {
        let urlString = "\(baseURL)/v1/block/\(hash)/txs/\(startIndex)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Transaction Methods
    
    func fetchTransaction(txid: String) -> AnyPublisher<Transaction, Error> {
        let urlString = "\(baseURL)/v1/tx/\(txid)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Transaction.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchMempoolTransactions() -> AnyPublisher<[Transaction], Error> {
        let urlString = "\(baseURL)/v1/mempool/recent"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Address Methods
    
    func fetchAddressUTXOs(address: String) -> AnyPublisher<[UTXO], Error> {
        let urlString = "\(baseURL)/v1/address/\(address)/utxo"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [UTXO].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchAddressTransactions(address: String) -> AnyPublisher<[Transaction], Error> {
        let urlString = "\(baseURL)/v1/address/\(address)/txs"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Network Statistics
    
    func fetchNetworkStats() -> AnyPublisher<NetworkStats, Error> {
        let urlString = "\(baseURL)/v1/fees/recommended"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NetworkStats.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchMempoolInfo() -> AnyPublisher<MempoolInfo, Error> {
        let urlString = "\(baseURL)/v1/mempool"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MempoolInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Real-time Updates
    
    private func startPeriodicUpdates() {
        // Update network stats every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateNetworkStats()
            }
            .store(in: &cancellables)
        
        // Update mempool every 10 seconds
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMempool()
            }
            .store(in: &cancellables)
        
        // Update recent blocks every 60 seconds
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRecentBlocks()
            }
            .store(in: &cancellables)
    }
    
    private func updateNetworkStats() {
        fetchNetworkStats()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch network stats: \(error)")
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.averageFee = stats.fastestFee
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateMempool() {
        fetchMempoolInfo()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch mempool info: \(error)")
                    }
                },
                receiveValue: { [weak self] info in
                    self?.mempoolSize = info.count
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateRecentBlocks() {
        fetchBlocks(limit: 10)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch recent blocks: \(error)")
                    }
                },
                receiveValue: { [weak self] blocks in
                    self?.recentBlocks = blocks
                    self?.currentHeight = blocks.first?.height ?? 0
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

struct NetworkStats: Codable {
    let fastestFee: Double
    let halfHourFee: Double
    let hourFee: Double
    let economyFee: Double
    let minimumFee: Double
}

struct MempoolInfo: Codable {
    let count: Int
    let vsize: Int
    let total_fee: Int
    let fee_histogram: [[Int]]
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

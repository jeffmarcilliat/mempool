import Foundation

struct Block: Identifiable, Codable, Equatable {
    let id: String
    let height: Int
    let timestamp: Int
    let txCount: Int
    let size: Int
    let weight: Int
    let difficulty: Double

    var blockTime: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    var feeRate: Double {
        // Since we don't have total_fees, we'll use a default calculation
        // or we can make this optional
        return 0.0
    }
    
    var visualSize: Float {
        // Calculate visual size based on transaction count
        return Float(txCount) / 1000.0 + 0.1
    }

    enum CodingKeys: String, CodingKey {
        case id
        case height
        case timestamp
        case txCount = "tx_count"
        case size
        case weight
        case difficulty
    }
}

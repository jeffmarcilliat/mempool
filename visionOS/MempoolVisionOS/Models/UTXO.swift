import Foundation

struct UTXO: Identifiable, Codable, Equatable {
    let id: String
    let txid: String
    let vout: Int
    let value: Int
    let scriptpubkeyType: String
    let scriptpubkeyAddress: String?
    let blockHeight: Int?
    let blockTime: Int?
    
    var btcValue: Double {
        Double(value) / 100_000_000.0
    }
    
    var visualSize: Float {
        // Calculate visual size based on value
        return Float(value) / 100_000_000.0 + 0.02
    }

    enum CodingKeys: String, CodingKey {
        case id
        case txid
        case vout
        case value
        case scriptpubkeyType = "scriptpubkey_type"
        case scriptpubkeyAddress = "scriptpubkey_address"
        case blockHeight = "block_height"
        case blockTime = "block_time"
    }
}

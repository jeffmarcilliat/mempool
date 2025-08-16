import Foundation

struct UTXO: Identifiable, Codable {
    let id: String // Combination of txid and vout
    let txid: String
    let vout: Int
    let value: Int
    let status: UTXOStatus
    let scriptpubkey: String
    let scriptpubkeyAsm: String
    let scriptpubkeyType: String
    let scriptpubkeyAddress: String?
    let blockHeight: Int?
    let blockTime: Int?
    let asset: String?
    let confidential: Bool?
    
    // Computed properties
    var btcValue: Double {
        Double(value) / 100_000_000.0 // Convert satoshis to BTC
    }
    
    var isSpent: Bool {
        !status.confirmed
    }
    
    // 3D visualization properties
    var visualSize: Float {
        let baseSize: Float = 0.02
        let valueMultiplier = Float(value) / 100_000_000.0 // Scale based on BTC value
        return baseSize + (valueMultiplier * 0.1)
    }
    
    var visualColor: String {
        if value > 1_000_000_000 { // > 10 BTC
            return "gold"
        } else if value > 100_000_000 { // > 1 BTC
            return "orange"
        } else if value > 10_000_000 { // > 0.1 BTC
            return "yellow"
        } else {
            return "green"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case txid
        case vout
        case value
        case status
        case scriptpubkey
        case scriptpubkeyAsm = "scriptpubkey_asm"
        case scriptpubkeyType = "scriptpubkey_type"
        case scriptpubkeyAddress = "scriptpubkey_address"
        case blockHeight = "block_height"
        case blockTime = "block_time"
        case asset
        case confidential
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        txid = try container.decode(String.self, forKey: .txid)
        vout = try container.decode(Int.self, forKey: .vout)
        value = try container.decode(Int.self, forKey: .value)
        status = try container.decode(UTXOStatus.self, forKey: .status)
        scriptpubkey = try container.decode(String.self, forKey: .scriptpubkey)
        scriptpubkeyAsm = try container.decode(String.self, forKey: .scriptpubkeyAsm)
        scriptpubkeyType = try container.decode(String.self, forKey: .scriptpubkeyType)
        scriptpubkeyAddress = try container.decodeIfPresent(String.self, forKey: .scriptpubkeyAddress)
        blockHeight = try container.decodeIfPresent(Int.self, forKey: .blockHeight)
        blockTime = try container.decodeIfPresent(Int.self, forKey: .blockTime)
        asset = try container.decodeIfPresent(String.self, forKey: .asset)
        confidential = try container.decodeIfPresent(Bool.self, forKey: .confidential)
        
        // Generate unique ID
        id = "\(txid):\(vout)"
    }
}

struct UTXOStatus: Codable {
    let confirmed: Bool
    let blockHeight: Int?
    let blockHash: String?
    let blockTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case confirmed
        case blockHeight = "block_height"
        case blockHash = "block_hash"
        case blockTime = "block_time"
    }
}

// Extension for UTXO collections
extension Array where Element == UTXO {
    var totalValue: Int {
        reduce(0) { $0 + $1.value }
    }
    
    var totalBTCValue: Double {
        Double(totalValue) / 100_000_000.0
    }
    
    var byAddress: [String: [UTXO]] {
        Dictionary(grouping: self) { utxo in
            utxo.scriptpubkeyAddress ?? "unknown"
        }
    }
    
    var byScriptType: [String: [UTXO]] {
        Dictionary(grouping: self) { utxo in
            utxo.scriptpubkeyType
        }
    }
}

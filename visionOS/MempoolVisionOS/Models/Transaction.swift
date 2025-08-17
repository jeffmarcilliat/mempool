import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: String
    let fee: Int
    let size: Int
    let weight: Int
    let status: TransactionStatus
    let vin: [TransactionInput]
    let vout: [TransactionOutput]
    
    var feeRate: Double {
        guard weight > 0 else { return 0 }
        return Double(fee) / Double(weight) * 4.0
    }
    
    var visualSize: Float {
        // Calculate visual size based on transaction size
        return Float(size) / 1000.0 + 0.05
    }

    struct TransactionStatus: Codable, Equatable {
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
    
    struct TransactionInput: Codable, Equatable {
        let txid: String
        let vout: Int
        let prevout: TransactionOutput?
        let scriptsig: String
        let witness: [String]?
    }
    
    struct TransactionOutput: Codable, Equatable {
        let scriptpubkey: String
        let scriptpubkeyAsm: String
        let scriptpubkeyType: String
        let scriptpubkeyAddress: String?
        let value: Int
        
        enum CodingKeys: String, CodingKey {
            case scriptpubkey
            case scriptpubkeyAsm = "scriptpubkey_asm"
            case scriptpubkeyType = "scriptpubkey_type"
            case scriptpubkeyAddress = "scriptpubkey_address"
            case value
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "txid"
        case fee
        case size
        case weight
        case status
        case vin
        case vout
    }
}

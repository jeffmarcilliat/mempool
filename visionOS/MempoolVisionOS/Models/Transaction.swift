import Foundation

struct Transaction: Identifiable, Codable {
    let id: String // Transaction ID
    let version: Int
    let locktime: Int
    let size: Int
    let weight: Int
    let fee: Int
    let vin: [TransactionInput]
    let vout: [TransactionOutput]
    let status: TransactionStatus
    
    // Additional properties for mempool transactions
    let firstSeen: Int?
    let feePerVsize: Double?
    let effectiveFeePerVsize: Double?
    let ancestors: [Ancestor]?
    let descendants: [Ancestor]?
    let bestDescendant: BestDescendant?
    let cpfpChecked: Bool?
    let acceleration: Bool?
    let acceleratedBy: [Int]?
    let acceleratedAt: Int?
    let feeDelta: Int?
    let deleteAfter: Int?
    let sigops: Int?
    let flags: Int?
    let largeInput: Bool?
    let largeOutput: Bool?
    
    // Computed properties for visualization
    var feeRate: Double {
        guard weight > 0 else { return 0 }
        return Double(fee) / Double(weight) * 4.0 // Convert to sat/vB
    }
    
    var totalInputValue: Int {
        vin.reduce(0) { $0 + ($1.prevout?.value ?? 0) }
    }
    
    var totalOutputValue: Int {
        vout.reduce(0) { $0 + $1.value }
    }
    
    var isCoinbase: Bool {
        vin.first?.isCoinbase == true
    }
    
    // 3D visualization properties
    var visualSize: Float {
        let baseSize: Float = 0.05
        let sizeMultiplier = Float(size) / 1000.0
        return baseSize + (sizeMultiplier * 0.1)
    }
    
    var visualColor: String {
        if feeRate > 100 {
            return "red"
        } else if feeRate > 50 {
            return "orange"
        } else if feeRate > 20 {
            return "yellow"
        } else {
            return "green"
        }
    }
    
    var isConfirmed: Bool {
        status.confirmed
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "txid"
        case version
        case locktime
        case size
        case weight
        case fee
        case vin
        case vout
        case status
        case firstSeen = "first_seen"
        case feePerVsize = "fee_per_vsize"
        case effectiveFeePerVsize = "effective_fee_per_vsize"
        case ancestors
        case descendants
        case bestDescendant = "best_descendant"
        case cpfpChecked = "cpfp_checked"
        case acceleration
        case acceleratedBy = "accelerated_by"
        case acceleratedAt = "accelerated_at"
        case feeDelta = "fee_delta"
        case deleteAfter = "delete_after"
        case sigops
        case flags
        case largeInput = "large_input"
        case largeOutput = "large_output"
    }
}

struct TransactionInput: Codable {
    let txid: String
    let vout: Int
    let scriptsig: String
    let scriptsigAsm: String
    let sequence: Int
    let isCoinbase: Bool
    let prevout: TransactionOutput?
    let witness: [String]?
    let innerWitnessscriptAsm: String?
    
    enum CodingKeys: String, CodingKey {
        case txid
        case vout
        case scriptsig
        case scriptsigAsm = "scriptsig_asm"
        case sequence
        case isCoinbase = "is_coinbase"
        case prevout
        case witness
        case innerWitnessscriptAsm = "inner_witnessscript_asm"
    }
}

struct TransactionOutput: Codable {
    let scriptpubkey: String
    let scriptpubkeyAsm: String
    let scriptpubkeyType: String
    let scriptpubkeyAddress: String?
    let value: Int
    let asset: String?
    let confidential: Bool?
    
    enum CodingKeys: String, CodingKey {
        case scriptpubkey
        case scriptpubkeyAsm = "scriptpubkey_asm"
        case scriptpubkeyType = "scriptpubkey_type"
        case scriptpubkeyAddress = "scriptpubkey_address"
        case value
        case asset
        case confidential
    }
}

struct TransactionStatus: Codable {
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

struct Ancestor: Codable {
    let txid: String
    let weight: Int
    let fee: Int
}

struct BestDescendant: Codable {
    let txid: String
    let weight: Int
    let fee: Int
}

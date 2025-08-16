import Foundation

struct Block: Identifiable, Codable {
    let id: String // Block hash
    let height: Int
    let version: Int
    let timestamp: Int
    let bits: Int
    let nonce: Int
    let difficulty: Double
    let merkleRoot: String
    let txCount: Int
    let size: Int
    let weight: Int
    let previousBlockHash: String
    let medianTime: Int
    let totalFees: Int
    let medianFee: Int
    let feeRange: String
    let reward: Int
    let poolId: Int?
    let poolName: String?
    let poolSlug: String?
    let avgFee: Int
    let avgFeeRate: Double
    let coinbaseRaw: String?
    let coinbaseAddress: String?
    let coinbaseAddresses: String?
    let coinbaseSignature: String?
    let coinbaseSignatureAscii: String?
    let avgTxSize: Int
    let totalInputs: Int
    let totalOutputs: Int
    let totalOutputAmt: Int
    let medianFeeAmt: Int
    let feePercentiles: String?
    let segwitTotalTxs: Int
    let segwitTotalSize: Int
    let segwitTotalWeight: Int
    let header: String?
    let utxoSetChange: Int
    let utxoSetSize: Int
    let totalInputAmt: Int
    let firstSeen: Int?
    
    // Computed properties for visualization
    var blockTime: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    var feeRate: Double {
        guard weight > 0 else { return 0 }
        return Double(totalFees) / Double(weight) * 4.0 // Convert to sat/vB
    }
    
    var blockSize: Double {
        Double(size) / 1024.0 / 1024.0 // Convert to MB
    }
    
    var blockWeight: Double {
        Double(weight) / 4.0 / 1024.0 / 1024.0 // Convert to MB
    }
    
    // 3D visualization properties
    var visualSize: Float {
        // Scale block size for 3D representation
        let baseSize: Float = 0.1
        let sizeMultiplier = Float(txCount) / 1000.0 // Scale based on transaction count
        return baseSize + (sizeMultiplier * 0.2)
    }
    
    var visualColor: String {
        // Color based on fee rate
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
    
    enum CodingKeys: String, CodingKey {
        case id = "hash"
        case height
        case version
        case timestamp
        case bits
        case nonce
        case difficulty
        case merkleRoot = "merkle_root"
        case txCount = "tx_count"
        case size
        case weight
        case previousBlockHash = "previous_block_hash"
        case medianTime = "median_time"
        case totalFees = "total_fees"
        case medianFee = "median_fee"
        case feeRange = "fee_range"
        case reward
        case poolId = "pool_id"
        case poolName = "pool_name"
        case poolSlug = "pool_slug"
        case avgFee = "avg_fee"
        case avgFeeRate = "avg_fee_rate"
        case coinbaseRaw = "coinbase_raw"
        case coinbaseAddress = "coinbase_address"
        case coinbaseAddresses = "coinbase_addresses"
        case coinbaseSignature = "coinbase_signature"
        case coinbaseSignatureAscii = "coinbase_signature_ascii"
        case avgTxSize = "avg_tx_size"
        case totalInputs = "total_inputs"
        case totalOutputs = "total_outputs"
        case totalOutputAmt = "total_output_amt"
        case medianFeeAmt = "median_fee_amt"
        case feePercentiles = "fee_percentiles"
        case segwitTotalTxs = "segwit_total_txs"
        case segwitTotalSize = "segwit_total_size"
        case segwitTotalWeight = "segwit_total_weight"
        case header
        case utxoSetChange = "utxo_set_change"
        case utxoSetSize = "utxo_set_size"
        case totalInputAmt = "total_input_amt"
        case firstSeen = "first_seen"
    }
}

import Foundation

struct MempoolStrata: Identifiable, Codable {
    let id = UUID()
    let feeRange: ClosedRange<Double>
    let transactionCount: Int
    let totalSize: Int
    let averageFee: Double
    let color: StrataColor
    
    enum StrataColor: String, Codable, CaseIterable {
        case red = "high"      
        case orange = "medium" 
        case yellow = "low"    
        case green = "minimal" 
    }
    
    var visualHeight: Float {
        return Float(transactionCount) / 1000.0 * Float(averageFee) / 50.0
    }
}

struct MempoolData: Codable {
    let strata: [MempoolStrata]
    let totalTransactions: Int
    let recommendedFees: RecommendedFees
}

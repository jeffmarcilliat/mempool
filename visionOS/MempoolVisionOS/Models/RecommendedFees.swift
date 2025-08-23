import Foundation

struct RecommendedFees: Codable {
    let fastestFee: Int
    let halfHourFee: Int  
    let hourFee: Int
    let economyFee: Int
    let minimumFee: Int
}

struct SearchResult: Identifiable, Codable {
    let id = UUID()
    let type: SearchResultType
    let title: String
    let subtitle: String
    
    enum SearchResultType: String, Codable {
        case transaction
        case address
        case block
    }
}

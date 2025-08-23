import SwiftUI

struct FeePanelView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fee Recommendations")
                .font(.headline)
                .foregroundColor(.white)
            
            if let fees = viewModel.recommendedFees {
                HStack(spacing: 20) {
                    FeeOptionView(
                        title: "Fast",
                        fee: fees.fastestFee,
                        time: "~10 min",
                        color: .red
                    )
                    
                    FeeOptionView(
                        title: "Medium", 
                        fee: fees.halfHourFee,
                        time: "~30 min",
                        color: .orange
                    )
                    
                    FeeOptionView(
                        title: "Slow",
                        fee: fees.hourFee, 
                        time: "~1 hour",
                        color: .green
                    )
                }
            } else {
                ProgressView("Loading fees...")
                    .foregroundColor(.white)
            }
            
            HStack {
                Circle()
                    .fill(viewModel.isConnectedToWebSocket ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(viewModel.isConnectedToWebSocket ? "Live" : "Offline")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            viewModel.connectToRealTimeData()
        }
    }
}

struct FeeOptionView: View {
    let title: String
    let fee: Int
    let time: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(color)
            Text("\(fee)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("sat/vB")
                .font(.caption2)
                .foregroundColor(.gray)
            Text(time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

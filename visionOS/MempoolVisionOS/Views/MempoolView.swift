import SwiftUI

struct MempoolView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        VStack {
            if !viewModel.mempoolStrata.isEmpty {
                Text("Mempool Fee Strata")
                    .font(.title2)
                    .padding()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.mempoolStrata.enumerated()), id: \.element.id) { index, stratum in
                            MempoolStrataRow(stratum: stratum, index: index)
                        }
                    }
                    .padding()
                }
            } else {
                List(viewModel.mempoolTransactions.prefix(50), id: \.id) { transaction in
                    VStack(alignment: .leading) {
                        Text("TX: \(transaction.id.prefix(16))...")
                            .font(.headline)
                        Text("Fee: \(transaction.fee) sats")
                        Text("Fee Rate: \(transaction.feeRate, specifier: "%.2f") sat/vB")
                        Text("Size: \(transaction.size) bytes")
                    }
                    .onTapGesture {
                        viewModel.selectTransaction(transaction)
                    }
                }
            }
        }
        .navigationTitle("Mempool")
        .onAppear {
            viewModel.connectToRealTimeData()
        }
    }
}

struct MempoolStrataRow: View {
    let stratum: MempoolStrata
    let index: Int
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(colorForStratum(stratum.color))
                .frame(width: 20, height: 40)
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Layer \(index + 1)")
                    .font(.headline)
                Text("\(stratum.transactionCount) transactions")
                    .font(.subheadline)
                Text("Avg Fee: \(stratum.averageFee, specifier: "%.1f") sat/vB")
                    .font(.caption)
                Text("Range: \(stratum.feeRange.lowerBound, specifier: "%.1f") - \(stratum.feeRange.upperBound, specifier: "%.1f") sat/vB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(stratum.totalSize) bytes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func colorForStratum(_ color: MempoolStrata.StrataColor) -> Color {
        switch color {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        }
    }
}

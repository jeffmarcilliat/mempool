import SwiftUI

struct MempoolView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
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
        .navigationTitle("Mempool")
    }
}

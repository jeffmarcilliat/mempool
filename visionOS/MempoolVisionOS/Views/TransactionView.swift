import SwiftUI

struct TransactionView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    
    var body: some View {
        if let transaction = viewModel.selectedTransaction {
            List {
                Section("Transaction Details") {
                    Text("ID: \(transaction.id)")
                    Text("Fee: \(transaction.fee) sats")
                    Text("Fee Rate: \(transaction.feeRate, specifier: "%.2f") sat/vB")
                    Text("Size: \(transaction.size) bytes")
                    Text("Weight: \(transaction.weight) WU")
                }
                
                Section("Inputs (\(transaction.vin.count))") {
                    ForEach(transaction.vin, id: \.txid) { input in
                        Text("\(input.txid.prefix(16))...:\(input.vout)")
                    }
                }
                
                Section("Outputs (\(transaction.vout.count))") {
                    ForEach(transaction.vout, id: \.scriptpubkey) { output in
                        VStack(alignment: .leading) {
                            Text("\(output.value) sats")
                            if let address = output.scriptpubkeyAddress {
                                Text(address)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transaction")
        } else {
            Text("No transaction selected")
        }
    }
}

import SwiftUI

struct SearchPanelView: View {
    @ObservedObject var viewModel: BlockchainViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("Transaction ID or Address", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        performSearch()
                    }
                
                Button("Search") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if isSearching {
                ProgressView("Searching...")
                    .foregroundColor(.white)
            } else if !viewModel.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.searchResults) { result in
                            SearchResultRow(result: result) {
                                handleResultSelection(result)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        Task {
            let results = await viewModel.searchTransactionOrAddress(searchText)
            await MainActor.run {
                self.isSearching = false
            }
        }
    }
    
    private func handleResultSelection(_ result: SearchResult) {
        switch result.type {
        case .transaction:
            Task {
                await viewModel.selectTransactionById(result.subtitle)
            }
        case .address:
            Task {
                await viewModel.searchAddressTransactions(result.subtitle)
            }
        case .block:
            if let blockHeight = Int(result.subtitle) {
                await viewModel.selectBlockByHeight(blockHeight)
            }
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(result.subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

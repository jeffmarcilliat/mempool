import SwiftUI

@main
struct MempoolVisionOSApp: App {
    @StateObject private var blockchainViewModel = BlockchainViewModel()
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            MainWindowView()
                .environmentObject(blockchainViewModel)
        }
        .defaultSize(width: 800, height: 600)
        
        // Immersive space for the blockchain experience
        ImmersiveSpace(id: "BlockchainSpace") {
            BlockchainImmersiveView(immersionStyle: $immersionStyle)
                .environmentObject(blockchainViewModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
    }
}

import SwiftUI

@main
struct MempoolVisionOSApp: App {
    @StateObject private var blockchainViewModel = BlockchainViewModel()
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    var body: some Scene {
        // Minimal window that automatically launches immersive space
        WindowGroup(id: "LaunchWindow") {
            LaunchView()
                .environmentObject(blockchainViewModel)
        }
        .defaultSize(width: 0.001, height: 0.001) // Nearly invisible
        
        // Direct immersive space for the blockchain experience
        ImmersiveSpace(id: "BlockchainSpace") {
            BlockchainImmersiveView(immersionStyle: $immersionStyle)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
    }
}

struct LaunchView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var hasLaunchedImmersive = false
    
    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .onAppear {
                if !hasLaunchedImmersive {
                    hasLaunchedImmersive = true
                    Task {
                        await openImmersiveSpace(id: "BlockchainSpace")
                    }
                }
            }
    }
}

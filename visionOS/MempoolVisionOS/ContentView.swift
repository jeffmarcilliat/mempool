import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var hasLaunchedImmersive = false
    
    var body: some View {
        // Completely invisible view
        Color.clear
            .allowsHitTesting(false) // Disable all interaction
            .onAppear {
                if !hasLaunchedImmersive {
                    hasLaunchedImmersive = true
                    // Automatically launch immersive experience when app starts
                    Task {
                        await openImmersiveSpace(id: "BlockchainSpace")
                    }
                }
            }
    }
}
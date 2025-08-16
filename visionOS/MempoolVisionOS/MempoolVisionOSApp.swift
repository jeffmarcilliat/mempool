import SwiftUI

@main
struct MempoolVisionOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 0.5, in: .meters)
    }
}

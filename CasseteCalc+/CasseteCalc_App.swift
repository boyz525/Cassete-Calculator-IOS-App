import SwiftUI

@main
struct CasseteCalc_App: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.light) // Light only by design
        }
    }
}

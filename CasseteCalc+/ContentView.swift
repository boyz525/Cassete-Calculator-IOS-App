import SwiftUI

// MARK: - Root Navigation
// All screen transitions live here — ZStack + slide animations.
// Cover designer, editor, onboarding are layers above the library base.
struct ContentView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ZStack {
            // ── Base: Library ──────────────────────────────────────
            LibraryView()

            // ── Layer 1: Editor ────────────────────────────────────
            if let id = app.editorCassetteId {
                EditorView(cassetteId: id)
                    .transition(.move(edge: .trailing))
                    .zIndex(10)
            }

            // ── Layer 2: Cover Designer ────────────────────────────
            if let id = app.coverCassetteId {
                CoverDesignerView(cassetteId: id)
                    .transition(.move(edge: .trailing))
                    .zIndex(20)
            }

            // ── Layer 3: Onboarding (disappears after first launch) ─
            if !app.hasSeenOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        app.markOnboardingDone()
                    }
                }
                .transition(.opacity)
                .zIndex(30)
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: app.editorCassetteId)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: app.coverCassetteId)
        .animation(.easeInOut(duration: 0.4), value: app.hasSeenOnboarding)
    }
}

#Preview {
    ContentView().environment(AppState())
}

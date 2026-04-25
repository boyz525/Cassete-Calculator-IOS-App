import SwiftUI
import Observation

// MARK: - App State
@Observable
final class AppState {
    var cassettes: [Cassette] = []
    var hasSeenOnboarding: Bool = false

    // Navigation
    var editorCassetteId: String?    // non-nil → push EditorView
    var coverCassetteId: String?     // non-nil → push CoverDesignerView (from editor)
    var showNewCassette: Bool = false

    private let repo = UserDefaultsRepository()

    init() {
        cassettes = repo.load()
        hasSeenOnboarding = repo.hasSeenOnboarding
    }

    // MARK: Persistence
    func persist() {
        repo.save(cassettes)
    }

    func markOnboardingDone() {
        hasSeenOnboarding = true
        repo.hasSeenOnboarding = true
    }

    // MARK: Cassette CRUD
    func cassette(id: String) -> Cassette? {
        cassettes.first { $0.id == id }
    }

    func upsert(_ cassette: Cassette) {
        var c = cassette
        c.updatedAt = Date()
        if let idx = cassettes.firstIndex(where: { $0.id == c.id }) {
            cassettes[idx] = c
        } else {
            cassettes.insert(c, at: 0)
        }
        persist()
    }

    func delete(id: String) {
        cassettes.removeAll { $0.id == id }
        persist()
    }

    func toggleFavorite(id: String) {
        guard let idx = cassettes.firstIndex(where: { $0.id == id }) else { return }
        cassettes[idx].isFavorite.toggle()
        persist()
    }

    func createNew(title: String, type: CassetteTypeId) -> Cassette {
        let id = UUID().uuidString
        let cassette = Cassette(
            id: id,
            title: title,
            subtitle: nil,
            type: type,
            cover: CassetteCover(style: .cream, label: title.lowercased(), year: "26"),
            sideA: [],
            sideB: [],
            updatedAt: Date()
        )
        cassettes.insert(cassette, at: 0)
        persist()
        return cassette
    }

    // MARK: Navigation helpers
    func openEditor(id: String) {
        editorCassetteId = id
    }

    func closeEditor() {
        editorCassetteId = nil
        coverCassetteId = nil
    }

    func openCoverDesigner() {
        coverCassetteId = editorCassetteId
    }

    func closeCoverDesigner() {
        coverCassetteId = nil
    }
}

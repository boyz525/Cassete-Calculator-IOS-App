import Foundation

// MARK: - Protocol
protocol CassetteRepository {
    var cassettes: [Cassette] { get }
    func save(_ cassettes: [Cassette])
    func load() -> [Cassette]
}

// MARK: - UserDefaults implementation
final class UserDefaultsRepository: CassetteRepository {
    private let cassettesKey  = "cassettes.v1"
    private let onboardingKey = "onboarding.v1.seen"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var cassettes: [Cassette] = []

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }

    func load() -> [Cassette] {
        guard let data = UserDefaults.standard.data(forKey: cassettesKey),
              let decoded = try? decoder.decode([Cassette].self, from: data) else {
            return seedCassettes  // First launch: seed data
        }
        return decoded
    }

    func save(_ cassettes: [Cassette]) {
        guard let data = try? encoder.encode(cassettes) else { return }
        UserDefaults.standard.set(data, forKey: cassettesKey)
    }
}

import SwiftUI

// MARK: - Cassette Type
enum CassetteTypeId: String, Codable, CaseIterable, Hashable {
    case c46, c60, c90, c120, custom

    var label: String {
        switch self {
        case .c46:    return "C-46"
        case .c60:    return "C-60"
        case .c90:    return "C-90"
        case .c120:   return "C-120"
        case .custom: return "Custom"
        }
    }
    var totalMinutes: Int? {
        switch self { case .c46: 46; case .c60: 60; case .c90: 90; case .c120: 120; case .custom: nil }
    }
    var sideSeconds: Double? {
        guard let m = totalMinutes else { return nil }
        return Double(m) * 30  // half the total = per-side in seconds
    }
}

// MARK: - Cover Style
enum CoverStyle: String, Codable, CaseIterable, Hashable {
    case peach, lavender, mint, butter, rose, sky, cream, ink

    var gradientColors: (Color, Color) {
        switch self {
        case .peach:    return (Color(hex: "#FFD6BA"), Color(hex: "#FFA27A"))
        case .lavender: return (Color(hex: "#E8DCFF"), Color(hex: "#B69BEB"))
        case .mint:     return (Color(hex: "#D8F4E3"), Color(hex: "#7AD4A6"))
        case .butter:   return (Color(hex: "#FFF3C4"), Color(hex: "#F5D06B"))
        case .rose:     return (Color(hex: "#FFD5DE"), Color(hex: "#F5859B"))
        case .sky:      return (Color(hex: "#D3E6F9"), Color(hex: "#82B6E8"))
        case .cream:    return (Color(hex: "#FFF7EA"), Color(hex: "#E8D9B8"))
        case .ink:      return (Color(hex: "#3A332E"), Color(hex: "#1A1512"))
        }
    }
    var gradient: LinearGradient {
        let (start, end) = gradientColors
        return LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var inkColor: Color {
        switch self {
        case .peach:    return Color(hex: "#5A2F1D")
        case .lavender: return Color(hex: "#3A2670")
        case .mint:     return Color(hex: "#15402C")
        case .butter:   return Color(hex: "#4A3406")
        case .rose:     return Color(hex: "#5E1E2E")
        case .sky:      return Color(hex: "#1A3756")
        case .cream:    return Color(hex: "#3D2E16")
        case .ink:      return Color(hex: "#F6F0E6")
        }
    }
    var accentColor: Color { gradientColors.1 }
    var displayName: String {
        switch self {
        case .peach:    return "Персик"
        case .lavender: return "Лаванда"
        case .mint:     return "Мята"
        case .butter:   return "Масло"
        case .rose:     return "Роза"
        case .sky:      return "Небо"
        case .cream:    return "Крем"
        case .ink:      return "Чернила"
        }
    }
}

// MARK: - Cassette Cover
struct CassetteCover: Codable, Equatable, Hashable {
    var style: CoverStyle = .cream
    var label: String = ""   // \n-separated, 2 lines max
    var year: String = "26"
}

// MARK: - Track
struct Track: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    var artist: String
    var dur: Double  // seconds
}

// MARK: - Cassette
struct Cassette: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    var subtitle: String?
    var type: CassetteTypeId
    var cover: CassetteCover
    var sideA: [Track]
    var sideB: [Track]
    var updatedAt: Date = Date()
    var isFavorite: Bool = false

    // MARK: Computed
    func totalSec(_ side: Side) -> Double {
        (side == .a ? sideA : sideB).reduce(0) { $0 + $1.dur }
    }
    var totalSecAll: Double { totalSec(.a) + totalSec(.b) }

    var capacityPerSide: Double { type.sideSeconds ?? .infinity }

    func fill(_ side: Side) -> Double {
        guard capacityPerSide != .infinity else { return 0 }
        return min(1, totalSec(side) / capacityPerSide)
    }
    func overflow(_ side: Side) -> Bool {
        guard capacityPerSide != .infinity else { return false }
        return totalSec(side) > capacityPerSide
    }
    func remaining(_ side: Side) -> Double {
        max(0, capacityPerSide - totalSec(side))
    }

    var updatedString: String {
        let interval = Date().timeIntervalSince(updatedAt)
        if interval < 3600    { return "только что" }
        if interval < 86400   { return "сегодня" }
        if interval < 172800  { return "вчера" }
        let days = Int(interval / 86400)
        if days < 7           { return "\(days) дн назад" }
        return "\(Int(days / 7)) нед назад"
    }

    enum Side: String { case a = "A", b = "B" }
}

// MARK: - Duration formatting
func fmtDur(_ sec: Double) -> String {
    let total = Int(sec)
    let m = total / 60
    let s = total % 60
    return String(format: "%d:%02d", m, s)
}

func fmtDurLong(_ sec: Double) -> String {
    let total = Int(sec)
    let m = total / 60
    let s = total % 60
    if s == 0 { return "\(m) мин" }
    return "\(m) мин \(s) сек"
}

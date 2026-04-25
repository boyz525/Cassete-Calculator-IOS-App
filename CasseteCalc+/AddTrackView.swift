import SwiftUI

// MARK: - Add Track Sheet
struct AddTrackView: View {
    let side: Cassette.Side
    let existingIds: Set<String>
    let remaining: Double  // seconds remaining on this side
    var onAdd: (Track) -> Void
    var onClose: () -> Void

    @State private var tab: Tab = .library
    @State private var query: String = ""
    @State private var manualTitle: String = ""
    @State private var manualArtist: String = ""
    @State private var manualMin: String = "3"
    @State private var manualSec: String = "30"
    @State private var bulkText: String = "Love Is Everywhere 4:12\nLate Night Drive 3:45\nOrange Sun 2:58"

    enum Tab: String, CaseIterable {
        case library = "Библиотека"
        case manual  = "Вручную"
        case bulk    = "Списком"
    }

    var filteredTracks: [Track] {
        trackLibrary.filter { t in
            !existingIds.contains(t.id) &&
            (query.isEmpty ||
             t.title.localizedCaseInsensitiveContains(query) ||
             t.artist.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Scrim
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            // Sheet panel — Liquid Glass
            sheetPanel
        }
        .ignoresSafeArea()
    }

    private var sheetPanel: some View {
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(Color.textPrimary.opacity(0.18))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 6)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Добавить трек")
                        .font(.system(size: 22, weight: .black))
                        .tracking(-0.6)
                        .foregroundStyle(Color.textPrimary)
                    if remaining > 0 {
                        Text("Осталось: \(fmtDurLong(remaining))")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                Spacer()
                GlassIconButton(size: 36, action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Tab switcher — Liquid Glass morphing pills
            GlassEffectContainer(spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(Tab.allCases, id: \.self) { t in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { tab = t }
                        } label: {
                            Text(t.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(tab == t ? Color.bgCream : Color.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .clipShape(Capsule(style: .continuous))
                                .glassEffect(
                                    tab == t
                                        ? Glass.regular.tint(Color(hex: "#1A1512").opacity(0.90))
                                        : Glass.regular.interactive(),
                                    in: Capsule(style: .continuous)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    switch tab {
                    case .library: libraryTab
                    case .manual:  manualTab
                    case .bulk:    bulkTab
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: tab)
            }
            .scrollIndicators(.hidden)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 30, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 30,
                style: .continuous
            )
        )
        .glassEffect(
            Glass.regular.tint(Color.bgCream.opacity(0.18)),
            in: UnevenRoundedRectangle(
                topLeadingRadius: 30, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 30,
                style: .continuous
            )
        )
    }

    // MARK: Library tab
    @ViewBuilder
    private var libraryTab: some View {
        // Search bar
        GlassCard(radius: 16) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                TextField("Поиск в библиотеке", text: $query)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textPrimary)
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .padding(.bottom, 10)

        GlassCard(radius: 20) {
            VStack(spacing: 0) {
                if filteredTracks.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textTertiary)
                        Text("Ничего не найдено")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(30)
                } else {
                    ForEach(Array(filteredTracks.enumerated()), id: \.element.id) { idx, track in
                        let fits = track.dur <= remaining
                        LibraryTrackRow(track: track, index: idx, fits: fits) {
                            if fits {
                                onAdd(track)
                                onClose()
                            }
                        }
                        if idx < filteredTracks.count - 1 {
                            Divider()
                                .overlay(Color.textPrimary.opacity(0.06))
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .padding(4)
        }
    }

    // MARK: Manual tab
    @ViewBuilder
    private var manualTab: some View {
        VStack(spacing: 10) {
            GlassCard(radius: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Название")
                        .font(.system(size: 11, weight: .bold)).tracking(1).textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                    TextField("Название трека", text: $manualTitle)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            GlassCard(radius: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Исполнитель")
                        .font(.system(size: 11, weight: .bold)).tracking(1).textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                    TextField("Исполнитель", text: $manualArtist)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            GlassCard(radius: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Длительность")
                        .font(.system(size: 11, weight: .bold)).tracking(1).textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                    HStack(alignment: .center, spacing: 6) {
                        TextField("3", text: $manualMin)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(width: 70)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.04)))
                            .keyboardType(.numberPad)
                        Text("мин").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                        TextField("30", text: $manualSec)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(width: 70)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.04)))
                            .keyboardType(.numberPad)
                        Text("сек").font(.system(size: 15)).foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }

            PrimaryButton(title: "Добавить трек", icon: "plus") {
                let dur = (Double(manualMin) ?? 0) * 60 + (Double(manualSec) ?? 0)
                guard !manualTitle.isEmpty, dur > 0 else { return }
                onAdd(Track(id: "m\(Date().timeIntervalSince1970)", title: manualTitle,
                            artist: manualArtist.isEmpty ? "—" : manualArtist, dur: dur))
                onClose()
            }
            .padding(.top, 8)
        }
    }

    // MARK: Bulk tab
    @ViewBuilder
    private var bulkTab: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("Формат: ")
                    .font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                Text("название мм:сс")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.bottom, 2)

            GlassCard(radius: 16) {
                TextEditor(text: $bulkText)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(Color.textPrimary)
                    .frame(minHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }

            PrimaryButton(title: "Добавить все", icon: "plus.circle") {
                let lines = bulkText.components(separatedBy: "\n")
                for (i, line) in lines.enumerated() {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { continue }
                    if let match = trimmed.range(of: #"^(.+?)\s+(\d+):(\d{1,2})\s*$"#,
                                                  options: .regularExpression) {
                        let full = String(trimmed[match])
                        let parts = full.components(separatedBy: " ")
                        if let last = parts.last, last.contains(":") {
                            let timeparts = last.components(separatedBy: ":")
                            let m = Double(timeparts[0]) ?? 0
                            let s = Double(timeparts.count > 1 ? timeparts[1] : "0") ?? 0
                            let title = parts.dropLast().joined(separator: " ")
                            onAdd(Track(id: "b\(Date().timeIntervalSince1970)\(i)",
                                       title: title, artist: "—", dur: m*60 + s))
                        }
                    }
                }
                onClose()
            }
        }
    }
}

// MARK: - Library Track Row
private struct LibraryTrackRow: View {
    let track: Track
    let index: Int
    let fits: Bool
    var onTap: () -> Void

    private let iconGradients: [(Color, Color)] = [
        (.pastelPeach, .pastelPeachDeep),
        (.pastelLavender, .pastelLavenderDeep),
        (.pastelMint, .pastelMintDeep),
        (.pastelButter, .pastelButterDeep),
        (.pastelRose, .pastelRoseDeep),
    ]

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                let g = iconGradients[index % iconGradients.count]
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [g.0, g.1], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .opacity(fits ? 1 : 0.4)

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 15, weight: .semibold)).tracking(-0.2)
                        .lineLimit(1).foregroundStyle(Color.textPrimary.opacity(fits ? 1 : 0.35))
                    Text(track.artist)
                        .font(.system(size: 13)).lineLimit(1)
                        .foregroundStyle(Color.textSecondary.opacity(fits ? 1 : 0.4))
                }

                Spacer()

                // Duration
                Text(fmtDur(track.dur))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.textSecondary.opacity(fits ? 1 : 0.35))

                // Add / disabled indicator
                if fits {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.textPrimary)
                } else {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!fits)
    }
}

#Preview {
    AddTrackView(
        side: .a,
        existingIds: [],
        remaining: 1800,
        onAdd: { _ in },
        onClose: {}
    )
}

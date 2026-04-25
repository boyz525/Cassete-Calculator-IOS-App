import SwiftUI

// MARK: - Library (Home) Screen
struct LibraryView: View {
    @Environment(AppState.self) private var app

    var cassettes: [Cassette] { app.cassettes }

    /// Favorites pinned to top, then sorted by updatedAt
    var sortedCassettes: [Cassette] {
        let favs = cassettes.filter { $0.isFavorite }.sorted { $0.updatedAt > $1.updatedAt }
        let rest = cassettes.filter { !$0.isFavorite }.sorted { $0.updatedAt > $1.updatedAt }
        return favs + rest
    }

    var totalTracks:  Int { cassettes.reduce(0) { $0 + $1.sideA.count + $1.sideB.count } }
    var totalMinutes: Int { Int(cassettes.reduce(0) { $0 + $1.totalSecAll } / 60) }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 54)

                    // ── Top bar ──────────────────────────────────
                    HStack {
                        GlassIconButton(size: 40) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                        Text("Моя коллекция")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        GlassIconButton(size: 40) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                    // ── Large title ──────────────────────────────
                    Text("Кассеты")
                        .font(.system(size: 40, weight: .black))
                        .tracking(-1.6)
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // ── Stats row ────────────────────────────────
                    HStack(spacing: 10) {
                        StatChip(value: "\(cassettes.count)", label: "кассет")
                        DotSeparator()
                        StatChip(value: "\(totalTracks)", label: "треков")
                        DotSeparator()
                        StatChip(value: "\(totalMinutes)", label: "мин")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    // ── Empty state ──────────────────────────────
                    if sortedCassettes.isEmpty {
                        emptyState
                    } else {
                        // Featured (first after sort — favorite or latest)
                        FeaturedCard(cassette: sortedCassettes[0]) {
                            app.openEditor(id: sortedCassettes[0].id)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)

                        // Grid
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 14
                        ) {
                            ForEach(sortedCassettes.dropFirst()) { c in
                                CassetteGridTile(cassette: c) {
                                    app.openEditor(id: c.id)
                                }
                            }
                            NewCassetteTile { app.showNewCassette = true }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer().frame(height: 130)
                }
            }
            .scrollIndicators(.hidden)

            // ── Floating Tab Bar ─────────────────────────────────
            libraryTabBar
                .padding(.bottom, 28)
        }
        .sheet(isPresented: Binding(
            get: { app.showNewCassette },
            set: { app.showNewCassette = $0 }
        )) {
            NewCassetteSheet()
                .environment(app)
                .presentationDetents([.medium])
                .presentationCornerRadius(30)
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            Color.bgCream
            RadialGradient(colors: [Color(hex: "#FFE5D0"), Color.clear],
                           center: .init(x: 0.1, y: 0.05), startRadius: 0, endRadius: 280)
            RadialGradient(colors: [Color(hex: "#E8DCFF"), Color.clear],
                           center: .init(x: 0.95, y: 0.15), startRadius: 0, endRadius: 240)
            RadialGradient(colors: [Color(hex: "#D8F4E3"), Color.clear],
                           center: .init(x: 0.5, y: 1.0), startRadius: 0, endRadius: 260)
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 20) {
            CassetteBodyView(
                cassette: Cassette(
                    id: "empty", title: "пусто", subtitle: nil, type: .c60,
                    cover: CassetteCover(style: .cream, label: "пусто", year: "26"),
                    sideA: [], sideB: [], updatedAt: Date()
                ),
                width: 260, isPlaying: false
            )
            .opacity(0.5)
            .padding(.top, 30)

            Text("Ещё нет кассет")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Создайте первую — выберите формат,\nнаполните треками и оформите обложку.")
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            PrimaryButton(title: "Создать кассету", icon: "plus") {
                app.showNewCassette = true
            }
            .padding(.horizontal, 40)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Floating tab bar (Liquid Glass)
    private var libraryTabBar: some View {
        FloatingGlassBar {
            HStack(spacing: 4) {
                // Active: Library tab
                ActiveTabPill {
                    HStack(spacing: 7) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Коллекция")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.bgCream)
                }

                // New cassette
                GlassTabButton(action: { app.showNewCassette = true }) {
                    HStack(spacing: 7) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Новая")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.textSecondary)
                }

                // Sparkle / random pick
                GlassTabButton(action: {
                    if let random = app.cassettes.randomElement() {
                        app.openEditor(id: random.id)
                    }
                }) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 20)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
        }
        .padding(.horizontal, 50)
    }
}

// MARK: - Featured Card
private struct FeaturedCard: View {
    let cassette: Cassette
    var onTap: () -> Void

    var fill: Double {
        guard let s = cassette.type.sideSeconds, s > 0 else { return 0 }
        return cassette.totalSecAll / (s * 2)
    }

    var body: some View {
        Button(action: onTap) {
            GlassCard(radius: Radius.xl) {
                HStack(spacing: 18) {
                    ZStack(alignment: .topTrailing) {
                        CassetteCoverView(cassette: cassette, size: 104, cornerRadius: 18)
                        if cassette.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#F5A623"))
                                        .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                                )
                                .offset(x: 6, y: -6)
                        }
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text("Недавняя")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.textSecondary)
                            if cassette.isFavorite {
                                Text("· В избранном")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color(hex: "#F5A623"))
                            }
                        }
                        .padding(.bottom, 6)

                        Text(cassette.title)
                            .font(.system(size: 22, weight: .bold))
                            .tracking(-0.6)
                            .lineLimit(1)
                            .foregroundStyle(Color.textPrimary)
                            .padding(.bottom, 4)

                        HStack(spacing: 4) {
                            Text("\(cassette.sideA.count + cassette.sideB.count) треков")
                            DotSeparator()
                            Text("\(Int(cassette.totalSecAll / 60)) мин")
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.bottom, 12)

                        HStack(spacing: 8) {
                            LiquidBarView(
                                fill: fill,
                                color1: .pastelPeach, color2: .pastelPeachDeep,
                                barHeight: 8, animated: false
                            )
                            Text(cassette.type.label)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(18)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Grid Tile
private struct CassetteGridTile: View {
    let cassette: Cassette
    var onTap: () -> Void

    @Environment(AppState.self) private var app

    var fill: Double {
        guard let s = cassette.type.sideSeconds, s > 0 else { return 0 }
        return cassette.totalSecAll / (s * 2)
    }

    var body: some View {
        Button(action: onTap) {
            GlassCard(radius: Radius.lg + 2) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        HStack {
                            Spacer()
                            CassetteCoverView(cassette: cassette, size: 110, cornerRadius: 16)
                            Spacer()
                        }
                        if cassette.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#F5A623"))
                                        .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                                )
                                .padding(.trailing, 8)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.bottom, 12)

                    Text(cassette.title)
                        .font(.system(size: 16, weight: .bold))
                        .tracking(-0.4)
                        .lineLimit(1)
                        .foregroundStyle(Color.textPrimary)
                        .padding(.bottom, 2)

                    HStack(spacing: 4) {
                        Text(cassette.type.label)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.textTertiary)
                        DotSeparator()
                        Text("\(cassette.sideA.count + cassette.sideB.count) тр.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.bottom, 8)

                    LiquidBarView(
                        fill: fill,
                        color1: cassette.cover.style.gradientColors.0,
                        color2: cassette.cover.style.gradientColors.1,
                        barHeight: 6, animated: false
                    )
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            // Favorite toggle
            Button {
                withAnimation { app.toggleFavorite(id: cassette.id) }
            } label: {
                Label(
                    cassette.isFavorite ? "Убрать из избранного" : "В избранное",
                    systemImage: cassette.isFavorite ? "star.slash" : "star"
                )
            }

            Divider()

            // Delete
            Button(role: .destructive) {
                withAnimation { app.delete(id: cassette.id) }
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

// MARK: - New Cassette Tile
private struct NewCassetteTile: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .glassEffect(.regular.interactive(), in: Circle())

                Text("Новая кассета")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text("Собрать с нуля")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg + 2, style: .continuous)
                    .fill(Color.white.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.lg + 2, style: .continuous)
                            .strokeBorder(
                                Color.textPrimary.opacity(0.18),
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                    }
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LibraryView().environment(AppState())
}

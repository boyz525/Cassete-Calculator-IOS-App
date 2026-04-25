import SwiftUI

// MARK: - Cover Designer Screen
struct CoverDesignerView: View {
    @Environment(AppState.self) private var app
    let cassetteId: String

    @State private var cover: CassetteCover = CassetteCover()
    @State private var floatOffset: CGFloat = 0

    private var cassette: Cassette? { app.cassette(id: cassetteId) }
    private var previewCassette: Cassette {
        guard var c = cassette else {
            return Cassette(id: cassetteId, title: "", subtitle: nil, type: .c60,
                           cover: cover, sideA: [], sideB: [], updatedAt: Date())
        }
        c.cover = cover
        return c
    }

    var body: some View {
        ZStack {
            // Dynamic background tinted with current cover
            Color.bgCream.ignoresSafeArea()
            let (c1, _) = cover.style.gradientColors
            RadialGradient(colors: [c1.opacity(0.4), Color.clear],
                           center: .init(x: 0.5, y: 0), startRadius: 0, endRadius: 300)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: cover.style)
            RadialGradient(colors: [Color(hex: "#E8DCFF"), Color.clear],
                           center: .init(x: 0.5, y: 1), startRadius: 0, endRadius: 220)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 54)

                    // Top bar
                    HStack {
                        GlassIconButton(size: 40, action: { app.closeCoverDesigner() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        Spacer()
                        Text("Обложка")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        GlassIconButton(size: 40, action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                let all = CoverStyle.allCases.filter { $0 != cover.style }
                                if let random = all.randomElement() { cover.style = random }
                            }
                        }) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                    // ── Live cover preview (cross-fades on style change) ─
                    ZStack {
                        CassetteCoverView(cassette: previewCassette, size: 200, cornerRadius: 24)
                            .id(cover.style)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: cover.style)
                    }
                    .offset(y: floatOffset)
                    .animation(.easeInOut(duration: 0.35).delay(0), value: cover.label)
                    .padding(.vertical, 28)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
                            floatOffset = -10
                        }
                    }

                    // ── Style name pill ───────────────────────────────────
                    HStack(spacing: 6) {
                        Circle()
                            .fill(cover.style.gradientColors.1)
                            .frame(width: 8, height: 8)
                        Text(cover.style.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .clipShape(Capsule(style: .continuous))
                    .glassEffect(.regular, in: Capsule(style: .continuous))
                    .animation(.easeInOut(duration: 0.2), value: cover.style)
                    .padding(.bottom, 20)

                    // ── Palette — horizontal scroll of tiny cover previews ─
                    GlassCard(radius: 22) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 6) {
                                Image(systemName: "paintpalette")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textSecondary)
                                Text("Палитра")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .textCase(.uppercase)
                                    .foregroundStyle(Color.textSecondary)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(CoverStyle.allCases, id: \.self) { style in
                                        CoverStyleSwatch(
                                            style: style,
                                            label: cover.label.isEmpty ? (cassette?.title ?? "") : cover.label,
                                            year: cover.year,
                                            isSelected: cover.style == style
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                cover.style = style
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                                .padding(.bottom, 4)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                        .padding(.bottom, 14)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    // ── Label input ───────────────────────────────────────
                    GlassCard(radius: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Надпись")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.textSecondary)
                            TextField("Название на обложке", text: $cover.label)
                                .font(.system(size: 22, weight: .bold))
                                .tracking(-0.5)
                                .foregroundStyle(Color.textPrimary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    // ── Year input ────────────────────────────────────────
                    GlassCard(radius: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Год")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .textCase(.uppercase)
                                    .foregroundStyle(Color.textSecondary)
                                TextField("26", text: $cover.year)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.textPrimary)
                                    .keyboardType(.numberPad)
                                    .onChange(of: cover.year) { _, new in
                                        if new.count > 2 { cover.year = String(new.prefix(2)) }
                                    }
                            }
                            Spacer()
                            Image(systemName: "clock")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.textTertiary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 130)
                }
            }
            .scrollIndicators(.hidden)

            // Save button
            VStack {
                Spacer()
                PrimaryButton(title: "Готово", icon: "checkmark") {
                    saveCover()
                    app.closeCoverDesigner()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let c = cassette { cover = c.cover }
        }
    }

    private func saveCover() {
        guard var c = cassette else { return }
        c.cover = cover
        app.upsert(c)
    }
}

// MARK: - Cover Style Swatch (tiny CassetteCoverView preview)
private struct CoverStyleSwatch: View {
    let style: CoverStyle
    let label: String
    let year: String
    let isSelected: Bool
    var onTap: () -> Void

    private var mockCassette: Cassette {
        Cassette(
            id: style.rawValue,
            title: label.isEmpty ? style.displayName : label,
            subtitle: nil,
            type: .c60,
            cover: CassetteCover(style: style, label: label.isEmpty ? style.displayName : label, year: year),
            sideA: [], sideB: [], updatedAt: Date()
        )
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    CassetteCoverView(cassette: mockCassette, size: 68, cornerRadius: 12)
                        .scaleEffect(isSelected ? 1.06 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.textPrimary, lineWidth: 2.5)
                            .frame(width: 68 + 4, height: 68 * 1.5 + 4)

                        // Checkmark badge
                        Circle()
                            .fill(Color.textPrimary)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.bgCream)
                            }
                            .frame(width: 68, height: 68 * 1.5, alignment: .topTrailing)
                            .offset(x: 8, y: -8)
                    }
                }
                .frame(width: 68, height: 68 * 1.5)

                Text(style.displayName)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CoverDesignerView(cassetteId: seedCassettes[0].id)
        .environment({
            let s = AppState()
            return s
        }())
}

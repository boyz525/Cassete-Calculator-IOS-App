import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Editor Screen
struct EditorView: View {
    @Environment(AppState.self) private var app
    let cassetteId: String

    @State private var cassette: Cassette = Cassette(
        id: "", title: "", subtitle: nil, type: .c60,
        cover: CassetteCover(), sideA: [], sideB: [], updatedAt: Date()
    )
    @State private var activeSide: Cassette.Side = .a
    @State private var isPlaying: Bool = false
    @State private var showAdd: Bool = false
    @State private var showDeleteConfirm: Bool = false

    // Overflow rejection
    @State private var overflowToast: Bool = false
    @State private var shakeOffset: CGFloat = 0

    private var type: CassetteTypeId  { cassette.type }
    private var capacity: Double      { cassette.capacityPerSide }
    private var secA: Double          { cassette.totalSec(.a) }
    private var secB: Double          { cassette.totalSec(.b) }
    private var ovA: Bool             { cassette.overflow(.a) }
    private var ovB: Bool             { cassette.overflow(.b) }
    private var activeTracks: [Track] { activeSide == .a ? cassette.sideA : cassette.sideB }
    private var activeSec: Double     { activeSide == .a ? secA : secB }
    private var activeOverflow: Bool  { activeSide == .a ? ovA : ovB }
    private var activeRemaining: Double { cassette.remaining(activeSide) }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 54)

                    // ── Top bar ──────────────────────────────────
                    HStack(spacing: 10) {
                        GlassIconButton(size: 40, action: saveAndBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        Spacer()
                        // Play / pause
                        GlassIconButton(size: 40, action: { withAnimation { isPlaying.toggle() } }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        // Favorite toggle
                        GlassIconButton(size: 40, action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                app.toggleFavorite(id: cassetteId)
                                cassette.isFavorite.toggle()
                            }
                        }) {
                            Image(systemName: cassette.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 15))
                                .foregroundStyle(cassette.isFavorite ? Color(hex: "#F5A623") : Color.textPrimary)
                        }
                        // Delete
                        GlassIconButton(size: 40, action: {
                            withAnimation {
                                app.delete(id: cassetteId)
                                app.closeEditor()
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.danger)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // ── Type badge + editable title ───────────────
                    Text("\(type.label) · \(cassette.cover.style.displayName)")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)

                    TextField("Название кассеты", text: $cassette.title)
                        .font(.system(size: 34, weight: .black))
                        .tracking(-1.2)
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 14)
                        .onChange(of: cassette.title) { _, _ in debounceSave() }

                    // ── Physical cassette (tap = cover designer) ──
                    Button(action: { app.openCoverDesigner() }) {
                        CassetteBodyView(
                            cassette: cassette,
                            width: 320,
                            isPlaying: isPlaying
                        )
                        .rotationEffect(.degrees(-2))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.bottom, 6)
                    // Hint label under cassette
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                            Text("Нажмите для редактирования обложки")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color.textTertiary)
                        .padding(.bottom, 10)
                    }

                    // ── Side progress chips ───────────────────────
                    HStack(spacing: 8) {
                        SideProgressChip(
                            side: "A",
                            fill: cassette.fill(.a),
                            overflow: ovA,
                            color: Color.pastelPeachDeep
                        )
                        SideProgressChip(
                            side: "B",
                            fill: cassette.fill(.b),
                            overflow: ovB,
                            color: Color.pastelLavenderDeep
                        )
                        Spacer()
                        // Total duration pill
                        Text(fmtDur(cassette.totalSecAll))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .clipShape(Capsule(style: .continuous))
                            .glassEffect(in: Capsule(style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                    // ── Total summary card ────────────────────────
                    totalSummaryCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)

                    // ── Side switcher ─────────────────────────────
                    sideSwitcher
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                        .offset(x: shakeOffset)

                    // ── Track list ────────────────────────────────
                    trackList
                        .padding(.horizontal, 16)

                    // Remaining hint
                    remainingHint
                        .padding(.horizontal, 24)
                        .padding(.top, 14)

                    Spacer().frame(height: 130)
                }
            }
            .scrollIndicators(.hidden)

            // ── Overflow toast ────────────────────────────────────
            if overflowToast {
                ToastView(message: "Не влезает на сторону", isError: true)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .zIndex(100)
                    .allowsHitTesting(false)
            }

            // ── Add track floating bar ────────────────────────────
            addTrackBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { loadCassette() }
        .sheet(isPresented: $showAdd) {
            AddTrackView(
                side: activeSide,
                existingIds: Set(activeTracks.map(\.id)),
                remaining: activeRemaining,
                onAdd: addTrack,
                onClose: { showAdd = false }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(30)
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            Color.bgCream
            RadialGradient(colors: [Color(hex: "#FFE5D0"), Color.clear],
                           center: .init(x: 0.2, y: 0), startRadius: 0, endRadius: 250)
            RadialGradient(colors: [Color(hex: "#E8DCFF"), Color.clear],
                           center: .init(x: 0.85, y: 0.1), startRadius: 0, endRadius: 200)
            RadialGradient(colors: [Color(hex: "#D8F4E3"), Color.clear],
                           center: .init(x: 0.5, y: 0.95), startRadius: 0, endRadius: 230)
        }
    }

    // MARK: - Total summary card
    private var totalSummaryCard: some View {
        GlassCard(radius: Radius.xl) {
            VStack(spacing: 0) {
                HStack {
                    Text("Общая длительность")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1).textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(fmtDur(cassette.totalSecAll)) / \(fmtDur(capacity * 2))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.bottom, 10)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(Int(cassette.totalSecAll / 60))")
                        .font(.system(size: 46, weight: .black))
                        .tracking(-1.5)
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()
                    Text("мин \(String(format: "%02d", Int(cassette.totalSecAll) % 60)) сек")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    fitsBadge
                }
                .padding(.bottom, 14)

                // Two-side bars
                HStack(spacing: 10) {
                    sideBar("Сторона A", sec: secA, fill: cassette.fill(.a), overflow: ovA,
                            c1: .pastelPeach, c2: .pastelPeachDeep)
                    sideBar("Сторона B", sec: secB, fill: cassette.fill(.b), overflow: ovB,
                            c1: .pastelLavender, c2: .pastelLavenderDeep)
                }

                if ovA || ovB {
                    overflowWarning
                        .padding(.top, 12)
                }
            }
            .padding(18)
        }
    }

    private var fitsBadge: some View {
        let over = ovA || ovB
        return Text(over ? "Переполнено" : "Вмещается")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(over ? Color.danger : Color(hex: "#2E8F60"))
            .padding(.horizontal, 10).padding(.vertical, 4)
            .clipShape(Capsule())
            .glassEffect(
                over ? Glass.regular.tint(Color.danger.opacity(0.14))
                     : Glass.regular.tint(Color.success.opacity(0.2)),
                in: Capsule()
            )
    }

    @ViewBuilder
    private func sideBar(_ label: String, sec: Double, fill: Double, overflow: Bool,
                         c1: Color, c2: Color) -> some View {
        VStack(spacing: 5) {
            HStack {
                Text(label).font(.system(size: 11, weight: .bold))
                    .tracking(1).textCase(.uppercase)
                    .foregroundStyle(overflow ? Color.danger : Color.textSecondary)
                Spacer()
                Text(fmtDur(sec))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(overflow ? Color.danger : Color.textSecondary)
            }
            LiquidBarView(fill: fill, color1: c1, color2: c2, barHeight: 10, overflow: overflow)
        }
        .frame(maxWidth: .infinity)
    }

    private var overflowWarning: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13)).foregroundStyle(Color.danger)
            let side = ovA ? "A" : "B"
            let sec  = ovA ? secA : secB
            Text("Сторона \(side) переполнена на **\(fmtDur(sec - capacity))**")
                .font(.system(size: 13)).foregroundStyle(Color(hex: "#B83E3E"))
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .glassEffect(.regular.tint(Color.danger.opacity(0.1)),
                     in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Side switcher
    private var sideSwitcher: some View {
        HStack(spacing: 10) {
            ForEach([Cassette.Side.a, .b], id: \.self) { side in
                let isActive = activeSide == side
                let sec    = side == .a ? secA : secB
                let over   = side == .a ? ovA  : ovB
                let tracks = side == .a ? cassette.sideA : cassette.sideB

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { activeSide = side }
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Сторона \(side.rawValue) · \(tracks.count) тр.")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8).textCase(.uppercase)
                            .foregroundStyle(isActive
                                ? Color.bgCream.opacity(0.6)
                                : (over ? Color.danger : Color.textSecondary))

                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(fmtDur(sec))
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundStyle(isActive ? Color.bgCream : Color.textPrimary)
                            Spacer()
                            Text("/ \(fmtDur(capacity))")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(isActive ? Color.bgCream.opacity(0.5) : Color.textTertiary)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                    .glassEffect(
                        isActive
                            ? Glass.regular.tint(Color(hex: "#1A1512").opacity(0.88))
                            : Glass.regular,
                        in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    )
                    .shadow(color: isActive ? Color.black.opacity(0.2) : Color.clear, radius: 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Track list
    private var trackList: some View {
        GlassCard(radius: Radius.lg + 6) {
            VStack(spacing: 0) {
                if activeTracks.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "music.note")
                            .font(.system(size: 28)).foregroundStyle(Color.textTertiary)
                        Text("Треков пока нет")
                            .font(.system(size: 15, weight: .medium)).foregroundStyle(Color.textSecondary)
                        Text("Нажмите «Трек» ниже")
                            .font(.system(size: 13)).foregroundStyle(Color.textTertiary)
                    }
                    .padding(.vertical, 40).frame(maxWidth: .infinity)
                } else {
                    ForEach(Array(activeTracks.enumerated()), id: \.element.id) { idx, track in
                        TrackRow(track: track, number: idx + 1) { removeTrack(track.id) }
                        if idx < activeTracks.count - 1 {
                            Divider().overlay(Color.textPrimary.opacity(0.05)).padding(.leading, 50)
                        }
                    }
                    .onMove(perform: moveTrack)
                }
            }
            .padding(8)
        }
    }

    // MARK: - Remaining hint
    @ViewBuilder
    private var remainingHint: some View {
        if activeOverflow {
            Text("Превышение: \(fmtDur(activeSec - capacity))")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.danger)
        } else {
            (Text("Свободно на стороне \(activeSide.rawValue): ")
                .font(.system(size: 13)).foregroundStyle(Color.textSecondary)
            + Text(fmtDurLong(activeRemaining))
                .font(.system(size: 13, weight: .bold)).foregroundStyle(Color.textPrimary))
        }
    }

    // MARK: - Add track bar
    private var addTrackBar: some View {
        FloatingGlassBar {
            HStack(spacing: 10) {
                // Side dot
                Circle()
                    .fill(activeSide == .a ? Color.pastelPeachDeep : Color.pastelLavenderDeep)
                    .frame(width: 8, height: 8)
                    .shadow(color: (activeSide == .a
                        ? Color.pastelPeachDeep
                        : Color.pastelLavenderDeep).opacity(0.55), radius: 4)

                (Text("Добавить на ")
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(Color.textSecondary)
                + Text("сторону \(activeSide.rawValue)")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(Color.textPrimary))

                Spacer()

                Button { showAdd = true } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                        Text("Трек").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.bgCream)
                    .padding(.horizontal, 18).padding(.vertical, 11)
                    .background(Capsule().fill(Color.textPrimary)
                        .shadow(color: .black.opacity(0.25), radius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 20).padding(.vertical, 6).padding(.trailing, 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
    }

    // MARK: - Logic
    private func loadCassette() {
        guard let c = app.cassette(id: cassetteId) else { return }
        cassette = c
    }

    private func saveAndBack() {
        app.upsert(cassette)
        app.closeEditor()
    }

    private func debounceSave() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            app.upsert(cassette)
        }
    }

    private func addTrack(_ track: Track) {
        guard track.dur <= activeRemaining || cassette.type == .custom else {
            triggerOverflowRejection(); return
        }
        if activeSide == .a { cassette.sideA.append(track) }
        else                 { cassette.sideB.append(track) }
        app.upsert(cassette)
    }

    private func removeTrack(_ id: String) {
        if activeSide == .a { cassette.sideA.removeAll { $0.id == id } }
        else                { cassette.sideB.removeAll { $0.id == id } }
        app.upsert(cassette)
    }

    private func moveTrack(from: IndexSet, to: Int) {
        if activeSide == .a { cassette.sideA.move(fromOffsets: from, toOffset: to) }
        else                { cassette.sideB.move(fromOffsets: from, toOffset: to) }
        app.upsert(cassette)
    }

    private func triggerOverflowRejection() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        #endif
        let offsets: [CGFloat] = [6, -6, 6, -6, 6, -6, 0]
        for (i, offset) in offsets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation(.linear(duration: 0.045)) { shakeOffset = offset }
            }
        }
        withAnimation(.spring(response: 0.3)) { overflowToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) { overflowToast = false }
        }
    }
}

// MARK: - Track Row
private struct TrackRow: View {
    let track: Track
    let number: Int
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.05)))

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 15, weight: .semibold)).tracking(-0.2)
                    .lineLimit(1).foregroundStyle(Color.textPrimary)
                Text(track.artist)
                    .font(.system(size: 13)).lineLimit(1).foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(fmtDur(track.dur))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.textSecondary)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textTertiary)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10).padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    EditorView(cassetteId: seedCassettes[0].id).environment(AppState())
}

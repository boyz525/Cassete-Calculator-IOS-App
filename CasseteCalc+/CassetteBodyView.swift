import SwiftUI

// MARK: - Physical Cassette Body
// Full code-drawn cassette: body, window, reels, labels, screws
struct CassetteBodyView: View {
    var cassette: Cassette
    var width: CGFloat = 320
    var isPlaying: Bool = false
    @GestureState private var tiltX: CGFloat = 0

    var bodyHeight: CGFloat { width * 0.62 }
    var reelSize: CGFloat  { width * 0.22 }
    var windowW: CGFloat   { width * 0.68 }
    var windowH: CGFloat   { width * 0.28 }
    var windowY: CGFloat   { bodyHeight * 0.38 }  // center Y
    var fillA: Double      { cassette.fill(.a) }
    var fillB: Double      { cassette.fill(.b) }
    var cover: CoverStyle  { cassette.cover.style }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // ── Body background ──────────────────────────────────
            RoundedRectangle(cornerRadius: width * 0.06, style: .continuous)
                .fill(cover.gradient)
                .overlay {
                    // Subtle grain noise via fractal pattern approximation
                    RoundedRectangle(cornerRadius: width * 0.06, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.clear],
                                startPoint: .top, endPoint: .center
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.06, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
                }

            // ── Top label band ───────────────────────────────────
            HStack {
                Text(cassette.title.lowercased())
                    .font(.system(size: width * 0.04, weight: .bold, design: .default))
                    .letterSpacing(-0.02)
                    .lineLimit(1)
                Spacer()
                Text("Chrome · Type II")
                    .font(.system(size: width * 0.028, weight: .semibold, design: .monospaced))
                    .opacity(0.55)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .foregroundStyle(cover.inkColor)
            .padding(.horizontal, width * 0.06)
            .frame(width: width, height: width * 0.11)
            .offset(y: width * 0.04)

            // ── Window ──────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: width * 0.03, style: .continuous)
                    .fill(Color.black.opacity(0.85))
                    .overlay {
                        RoundedRectangle(cornerRadius: width * 0.03, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                            .padding(0.5)
                    }
                    .shadow(color: .black.opacity(0.6), radius: 4, y: 2)

                HStack(spacing: 0) {
                    // Left reel (Side A)
                    TapeReelView(size: reelSize, fill: fillA, isSpinning: isPlaying, clockwise: true)
                    Spacer()
                    // Right reel (Side B)
                    TapeReelView(size: reelSize, fill: fillB, isSpinning: isPlaying, clockwise: true)
                }
                .padding(.horizontal, width * 0.05)

                // Tape strip between reels
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6B4A2F"), Color(hex: "#3A2515"), Color(hex: "#6B4A2F")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(
                        width: windowW - reelSize * 2.2 - width * 0.1,
                        height: 1.5
                    )
            }
            .frame(width: windowW, height: windowH)
            .offset(x: (width - windowW) / 2, y: windowY - windowH / 2)

            // ── Bottom strip ─────────────────────────────────────
            HStack {
                SidePill(label: "Side A", inkColor: cover.inkColor)
                Spacer()
                ScrewDots(inkColor: cover.inkColor)
                Spacer()
                SidePill(label: "Side B", inkColor: cover.inkColor)
            }
            .padding(.horizontal, width * 0.08)
            .frame(width: width, height: width * 0.1)
            .offset(y: bodyHeight - width * 0.06 - width * 0.1)
        }
        .frame(width: width, height: bodyHeight)
        .warmShadowCassette()
        .rotation3DEffect(
            .degrees(Double(tiltX) * 4),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.4
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($tiltX) { value, state, _ in
                    let norm = (value.location.x / width - 0.5) * 2
                    state = norm
                }
        )
    }
}

// MARK: - Side A/B Pill
private struct SidePill: View {
    let label: String
    let inkColor: Color
    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 10, weight: .bold, design: .default))
            .tracking(1)
            .foregroundStyle(inkColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.35))
            )
    }
}

// MARK: - Screw Dots
private struct ScrewDots: View {
    let inkColor: Color
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color.black.opacity(0.18))
                    .overlay { Circle().strokeBorder(Color.black.opacity(0.3), lineWidth: 0.5) }
                    .frame(width: 7, height: 7)
            }
        }
    }
}

// MARK: - Letter spacing helper
extension Text {
    func letterSpacing(_ value: Double) -> Text {
        self.tracking(value)
    }
}

#Preview {
    CassetteBodyView(
        cassette: seedCassettes[0],
        width: 320,
        isPlaying: true
    )
    .padding(40)
    .background(Color.bgCream)
}

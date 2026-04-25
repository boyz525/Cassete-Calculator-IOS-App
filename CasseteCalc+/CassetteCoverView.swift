import SwiftUI

// MARK: - Cassette Cover Art (portrait card)
struct CassetteCoverView: View {
    var cassette: Cassette
    var size: CGFloat = 120
    var cornerRadius: CGFloat = 18

    var cover: CoverStyle { cassette.cover.style }
    var label: String     { cassette.cover.label.isEmpty ? cassette.title : cassette.cover.label }
    var year: String      { cassette.cover.year }
    var typeLabel: String {
        switch cassette.type {
        case .c46: return "C-46"; case .c60: return "C-60"
        case .c90: return "C-90"; case .c120: return "C-120"; case .custom: return "CSTM"
        }
    }
    var shortId: String   { String(cassette.id.suffix(2)) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient background
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(cover.gradient)

            // Grain overlay
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.clear],
                        startPoint: .top, endPoint: .center
                    )
                )
                .blendMode(.overlay)

            // Inner specular edge
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)

            // ── Top bar: type + № ──
            HStack {
                Text(typeLabel)
                Spacer()
                Text("№\(shortId)")
                    .fontDesign(.monospaced)
            }
            .font(.system(size: size * 0.08, weight: .semibold))
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(cover.inkColor.opacity(0.75))
            .padding(.horizontal, size * 0.09)
            .padding(.top, size * 0.07)

            // ── Big label (centered vertically) ──
            VStack(alignment: .leading, spacing: 0) {
                ForEach(label.components(separatedBy: "\n"), id: \.self) { line in
                    Text(line)
                }
            }
            .font(.system(size: size * 0.185, weight: .black, design: .default))
            .tracking(-1.5)
            .lineSpacing(-4)
            .foregroundStyle(cover.inkColor)
            .padding(.horizontal, size * 0.09)
            .frame(width: size, height: size * 1.5, alignment: .center)

            // ── Stripe ──
            Rectangle()
                .fill(cover.inkColor.opacity(0.3))
                .frame(height: 2)
                .padding(.horizontal, size * 0.09)
                .frame(width: size, height: size * 1.5, alignment: .bottom)
                .offset(y: -(size * 1.5 * 0.18))

            // ── Year ──
            Text("'\(year)")
                .font(.system(size: size * 0.09, weight: .bold, design: .default))
                .fontDesign(.monospaced)
                .foregroundStyle(cover.inkColor)
                .padding(.horizontal, size * 0.09)
                .padding(.bottom, size * 0.07)
                .frame(width: size, height: size * 1.5, alignment: .bottomLeading)
        }
        .frame(width: size, height: size * 1.5)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color(hex: "#503214").opacity(0.14), radius: 20, x: 0, y: 6)
        .shadow(color: Color(hex: "#503214").opacity(0.10), radius: 3, x: 0, y: 1)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        CassetteCoverView(cassette: seedCassettes[0], size: 100)
        CassetteCoverView(cassette: seedCassettes[1], size: 100)
        CassetteCoverView(cassette: seedCassettes[2], size: 100)
    }
    .padding(40)
    .background(Color.bgCream)
}

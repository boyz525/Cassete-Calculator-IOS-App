import SwiftUI

// MARK: - Liquid Fill Progress Bar
struct LiquidBarView: View {
    var fill: Double           // 0..1 (can exceed 1 for overflow)
    var color1: Color = .pastelPeach
    var color2: Color = .pastelPeachDeep
    var barHeight: CGFloat = 14   // renamed from "height" — conflicts with SwiftUI View.height in iOS 26
    var overflow: Bool = false
    var animated: Bool = true

    @State private var shimmerPhase: CGFloat = 0

    var clampedFill: Double { max(0, min(1, fill)) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color(hex: "#231B15").opacity(0.07))
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.08), Color.clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    }

                // Fill
                Capsule()
                    .fill(overflow
                        ? LinearGradient(colors: [Color(hex: "#FF8A8A"), Color.danger],
                                         startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [color1, color2],
                                         startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * clampedFill)
                    .overlay {
                        if animated {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .clear, location: 0),
                                            .init(color: .white.opacity(0.45), location: 0.5),
                                            .init(color: .clear, location: 1),
                                        ],
                                        startPoint: .init(x: shimmerPhase - 0.3, y: 0.5),
                                        endPoint: .init(x: shimmerPhase + 0.3, y: 0.5)
                                    )
                                )
                                .mask(Capsule())
                        }
                    }
                    // top gloss line
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(0.5))
                            .frame(height: 2)
                            .padding(.horizontal, 4)
                            .padding(.top, 2)
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: clampedFill)
                    .animation(.easeInOut(duration: 0.3), value: overflow)
            }
        }
        .frame(height: barHeight)
        .onAppear {
            guard animated else { return }
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.3
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LiquidBarView(fill: 0.65, color1: .pastelPeach, color2: .pastelPeachDeep, barHeight: 14)
        LiquidBarView(fill: 0.85, color1: .pastelLavender, color2: .pastelLavenderDeep, barHeight: 10)
        LiquidBarView(fill: 1.1, barHeight: 12, overflow: true)
    }
    .padding()
    .background(Color.bgCream)
}

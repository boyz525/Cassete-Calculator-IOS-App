import SwiftUI

// MARK: - Tape Reel
// Code-drawn cassette reel with spinning animation
struct TapeReelView: View {
    var size: CGFloat = 54
    var fill: Double = 0.5      // 0..1 = how much tape is on this reel
    var isSpinning: Bool = false
    var clockwise: Bool = true

    var body: some View {
        TimelineView(.animation(paused: !isSpinning)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = isSpinning
                ? (elapsed / 3.0).truncatingRemainder(dividingBy: 1.0) * (clockwise ? 1.0 : -1.0)
                : 0.0
            ReelCanvas(size: size, fill: fill, phase: phase)
        }
    }
}

// MARK: - Reel Canvas
struct ReelCanvas: View {
    var size: CGFloat
    var fill: Double      // 0..1
    var phase: Double     // rotation 0..1

    var body: some View {
        Canvas { ctx, _ in
            let cx = size / 2
            let cy = size / 2
            let outerR = size * 0.48
            let hubR   = size * 0.17
            let tapeR  = hubR + (outerR - hubR - 1) * max(0, min(1, fill))

            // ── Tape disc ──────────────────────────────────────────
            var tapePath = Path()
            tapePath.addArc(center: CGPoint(x: cx, y: cy),
                            radius: tapeR,
                            startAngle: .zero, endAngle: .degrees(360),
                            clockwise: false)
            ctx.fill(tapePath, with: .linearGradient(
                Gradient(stops: [
                    .init(color: Color(hex: "#6B4A2F"), location: 0),
                    .init(color: Color(hex: "#3A2515"), location: 0.6),
                    .init(color: Color(hex: "#1F130A"), location: 1),
                ]),
                startPoint: CGPoint(x: cx * 0.7, y: cy * 0.7),
                endPoint: CGPoint(x: cx * 1.3, y: cy * 1.3)
            ))

            // ── Concentric tape texture rings ───────────────────────
            if fill > 0.05 {
                let ringCount = Int((tapeR - hubR) / 1.5)
                for i in 0..<ringCount {
                    let r = hubR + CGFloat(i) * 1.5 + 0.8
                    var ring = Path()
                    ring.addArc(center: CGPoint(x: cx, y: cy),
                                radius: r,
                                startAngle: .zero, endAngle: .degrees(360),
                                clockwise: false)
                    ctx.stroke(ring, with: .color(Color.black.opacity(0.07)), lineWidth: 0.4)
                }
            }

            // ── Hub ────────────────────────────────────────────────
            let hubAngle = phase * 360
            ctx.translateBy(x: cx, y: cy)
            ctx.rotate(by: .degrees(hubAngle))
            ctx.translateBy(x: -cx, y: -cy)

            var hubPath = Path()
            hubPath.addArc(center: CGPoint(x: cx, y: cy),
                           radius: hubR,
                           startAngle: .zero, endAngle: .degrees(360),
                           clockwise: false)
            ctx.fill(hubPath, with: .color(Color(hex: "#2A2220")))

            // ── Teeth (6 spokes) ───────────────────────────────────
            for i in 0..<6 {
                let angle = Double(i) * 60.0 * .pi / 180.0
                let x1 = cx + cos(angle) * hubR * 0.35
                let y1 = cy + sin(angle) * hubR * 0.35
                let x2 = cx + cos(angle) * hubR * 0.78
                let y2 = cy + sin(angle) * hubR * 0.78
                var spoke = Path()
                spoke.move(to: CGPoint(x: x1, y: y1))
                spoke.addLine(to: CGPoint(x: x2, y: y2))
                ctx.stroke(spoke, with: .color(Color.white.opacity(0.2)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
            }

            // ── Center dot ─────────────────────────────────────────
            var dot = Path()
            dot.addArc(center: CGPoint(x: cx, y: cy),
                       radius: hubR * 0.22,
                       startAngle: .zero, endAngle: .degrees(360),
                       clockwise: false)
            ctx.fill(dot, with: .color(Color.white.opacity(0.3)))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 24) {
        TapeReelView(size: 60, fill: 0.3, isSpinning: true)
        TapeReelView(size: 60, fill: 0.7, isSpinning: true, clockwise: false)
    }
    .padding(30)
    .background(Color.black.opacity(0.85))
}

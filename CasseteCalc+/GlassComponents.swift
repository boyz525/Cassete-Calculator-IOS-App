import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - iOS 26 Liquid Glass Design System
//
// Rules:
//  • content → .clipShape(shape) → .glassEffect(in: shape)
//  • Interactive: .glassEffect(.regular.interactive(), in: shape)
//  • Grouped siblings that should morph: wrap in GlassEffectContainer
//  • Glass cannot sample glass — never stack without GlassEffectContainer
//  • Primary ink button stays dark (not glass) — per design spec
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    var radius: CGFloat = Radius.xl
    var strong: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .glassEffect(
                strong ? Glass.regular.tint(Color.white.opacity(0.12)) : Glass.regular,
                in: RoundedRectangle(cornerRadius: radius, style: .continuous)
            )
    }
}

// MARK: - Glass Icon Button
struct GlassIconButton<Label: View>: View {
    var size: CGFloat = 44
    var action: (() -> Void)? = nil
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button { action?() } label: {
            label()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Pill Row (bottom bars, search fields)
struct GlassPill<Content: View>: View {
    var radius: CGFloat = Radius.pill
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .clipShape(Capsule(style: .continuous))
            .glassEffect(.regular, in: Capsule(style: .continuous))
    }
}

// MARK: - Primary Button (dark ink — design spec, NOT glass)
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 17, weight: .semibold)) }
                Text(title).font(.system(size: 17, weight: .semibold))
            }
        }
        .buttonStyle(InkButtonStyle())
    }
}

struct InkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule(style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(hex: "#2A2220"), Color(hex: "#1A1512")],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
                    .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Ghost Button
struct GhostButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Floating Glass Bottom Bar
// Wraps children in GlassEffectContainer so tabs can morph together
struct FloatingGlassBar<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GlassEffectContainer(spacing: 6) {
            content()
        }
    }
}

// MARK: - Glass Active Tab Pill (filled dark)
struct ActiveTabPill<Label: View>: View {
    @ViewBuilder let label: () -> Label

    var body: some View {
        label()
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .clipShape(Capsule(style: .continuous))
            .glassEffect(.regular.tint(Color(hex: "#1A1512").opacity(0.92)), in: Capsule(style: .continuous))
    }
}

// MARK: - Glass Tab Button
struct GlassTabButton<Label: View>: View {
    var action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .clipShape(Capsule(style: .continuous))
                .glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toast (glass tinted)
struct ToastView: View {
    let message: String
    var isError: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            if isError {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.danger)
            }
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isError ? Color.danger : Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .clipShape(Capsule(style: .continuous))
        .glassEffect(
            isError
                ? Glass.regular.tint(Color.danger.opacity(0.18))
                : Glass.regular,
            in: Capsule(style: .continuous)
        )
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
    }
}

// MARK: - Dot separator
struct DotSeparator: View {
    var body: some View {
        Circle()
            .fill(Color.textTertiary)
            .frame(width: 3, height: 3)
    }
}

// MARK: - Stat Chip (library header)
struct StatChip: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 3) {
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .foregroundStyle(Color.textSecondary)
        }
        .font(.system(size: 15))
    }
}

// MARK: - Side Progress Chip
struct SideProgressChip: View {
    let side: String
    let fill: Double
    let overflow: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(overflow ? Color.danger : color)
                .frame(width: 6, height: 6)
            Text("Сторона \(side)")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(overflow ? Color.danger : Color.textSecondary)
            Text(overflow ? "!" : "\(Int(fill * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(overflow ? Color.danger : Color.textTertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .clipShape(Capsule(style: .continuous))
        .glassEffect(
            overflow
                ? Glass.regular.tint(Color.danger.opacity(0.12))
                : Glass.regular,
            in: Capsule(style: .continuous)
        )
    }
}

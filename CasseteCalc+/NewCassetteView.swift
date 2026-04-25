import SwiftUI

// MARK: - New Cassette Sheet
struct NewCassetteSheet: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var selectedType: CassetteTypeId = .c90

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#FFE5D0"), Color.clear],
                           center: .init(x: 0.15, y: 0), startRadius: 0, endRadius: 200)
                .ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#E8DCFF"), Color.clear],
                           center: .init(x: 0.85, y: 1), startRadius: 0, endRadius: 180)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.textPrimary.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 18)

                // Header
                Text("Новая кассета")
                    .font(.system(size: 22, weight: .black, design: .default))
                    .tracking(-0.6)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 24)

                // Title input
                GlassCard(radius: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Название")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.textSecondary)
                        TextField("Мой микс", text: $title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                // Type picker
                GlassCard(radius: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Формат")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.textSecondary)

                        GlassEffectContainer(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(CassetteTypeId.allCases.filter { $0 != .custom }, id: \.self) { type in
                                    TypePill(type: type, isSelected: selectedType == type) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                            selectedType = type
                                        }
                                    }
                                }
                            }
                        }

                        if let minutes = selectedType.totalMinutes {
                            HStack(spacing: 4) {
                                Text("\(minutes/2) мин на сторону")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.textSecondary)
                                Spacer()
                                Text("Всего \(minutes) мин")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Color.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)

                Spacer()

                // Create button
                PrimaryButton(
                    title: "Создать кассету",
                    icon: "plus",
                    action: {
                        guard isValid else { return }
                        let cassette = app.createNew(
                            title: title.trimmingCharacters(in: .whitespaces),
                            type: selectedType
                        )
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            app.openEditor(id: cassette.id)
                        }
                    }
                )
                .opacity(isValid ? 1 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}

private struct TypePill: View {
    let type: CassetteTypeId
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(type.label)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(isSelected ? Color.bgCream : Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .clipShape(Capsule(style: .continuous))
                .glassEffect(
                    isSelected
                        ? Glass.regular.tint(Color(hex: "#1A1512").opacity(0.90))
                        : Glass.regular.interactive(),
                    in: Capsule(style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NewCassetteSheet()
        .environment(AppState())
}

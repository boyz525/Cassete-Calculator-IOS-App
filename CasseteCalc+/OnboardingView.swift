import SwiftUI

// MARK: - Onboarding (3 steps)
struct OnboardingView: View {
    var onDone: () -> Void
    @State private var step = 0

    var body: some View {
        ZStack {
            // Warm radial gradient background
            Color.bgCream.ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#FFE5D0"), Color.clear],
                           center: .init(x: 0.2, y: 0.1), startRadius: 0, endRadius: 300)
                .ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#E8DCFF"), Color.clear],
                           center: .init(x: 0.9, y: 0.8), startRadius: 0, endRadius: 320)
                .ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "#D8F4E3"), Color.clear],
                           center: .init(x: 0.5, y: 1.0), startRadius: 0, endRadius: 280)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i == step ? Color.textPrimary : Color.textPrimary.opacity(0.18))
                            .frame(width: i == step ? 22 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: step)
                    }
                }
                .padding(.top, 64)

                // Slide content
                Group {
                    switch step {
                    case 0: HeroSlide()
                    case 1: CalcSlide()
                    default: CollectionSlide()
                    }
                }
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Buttons
                VStack(spacing: 10) {
                    PrimaryButton(
                        title: step < 2 ? "Далее" : "Начать",
                        action: {
                            if step < 2 {
                                withAnimation { step += 1 }
                            } else {
                                onDone()
                            }
                        }
                    )

                    if step < 2 {
                        GhostButton(title: "Пропустить", action: onDone)
                    } else {
                        Spacer().frame(height: 44)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Slide 1: Hero cassette
private struct HeroSlide: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Floating cassette
            CassetteBodyView(
                cassette: Cassette(
                    id: "ob1", title: "hello", subtitle: nil, type: .c90,
                    cover: CassetteCover(style: .peach, label: "hello", year: "26"),
                    sideA: [], sideB: [], updatedAt: Date()
                ),
                width: 280,
                isPlaying: true
            )
            .rotationEffect(.degrees(-4))
            .offset(y: floatOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    floatOffset = -14
                }
            }
            .padding(.bottom, 44)

            Text("Соберите\nидеальную кассету")
                .font(.system(size: 38, weight: .black, design: .default))
                .tracking(-1.4)
                .lineSpacing(-2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)
                .padding(.bottom, 14)

            Text("Калькулятор плёнки для тех,\nкто всё ещё слушает сторону A.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Slide 2: Calc preview
private struct CalcSlide: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Glass calc card mock
            GlassCard(radius: 28) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Сторона A · C-90")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.bottom, 10)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("38:42")
                            .font(.system(size: 44, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.textPrimary)
                        Text("/ 45:00")
                            .font(.system(size: 20, weight: .regular, design: .monospaced))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(.bottom, 12)

                    LiquidBarView(fill: 38.7/45, color1: .pastelPeach, color2: .pastelPeachDeep, barHeight: 14)

                    HStack {
                        Text("Ещё помещается:")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                        Text("6 мин 18 сек")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.top, 14)
                }
                .padding(22)
            }
            .frame(width: 280)
            .padding(.bottom, 40)

            Text("Точный расчёт\nдо секунды")
                .font(.system(size: 32, weight: .black, design: .default))
                .tracking(-1.2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)
                .padding(.bottom, 12)

            Text("Видите, сколько плёнки ещё свободно.\nНикаких обрезанных треков в конце.")
                .font(.system(size: 17))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Slide 3: Collection
private struct CollectionSlide: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Three staggered covers
            HStack(alignment: .center, spacing: 12) {
                CassetteCoverView(cassette: seedCassettes[0], size: 86)
                    .offset(y: 12)
                CassetteCoverView(cassette: seedCassettes[1], size: 86)
                CassetteCoverView(cassette: seedCassettes[2], size: 86)
                    .offset(y: 12)
            }
            .rotationEffect(.degrees(-3))
            .padding(.bottom, 40)

            Text("Красивая\nколлекция")
                .font(.system(size: 32, weight: .black, design: .default))
                .tracking(-1.2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)
                .padding(.bottom, 12)

            Text("Оформите обложки, сохраните в библиотеку\nи возвращайтесь когда угодно.")
                .font(.system(size: 17))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView { }
}

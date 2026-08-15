import SwiftUI

struct OnboardingSportsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    var step: Int
    var onContinue: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

    var body: some View {
        OnboardingScaffold(
            step: step,
            eyebrow: "Onboarding 2/3 — your sports",
            title: "What do you actually do?",
            subtitle: "Pick any. This decides which exercises show up first when you log.",
            buttonTitle: "Continue",
            onContinue: onContinue
        ) {
            VStack(alignment: .leading, spacing: 24) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                    ForEach(SportType.allCases) { sport in
                        MovoChip(
                            title: sport.displayName,
                            isSelected: store.onboarding.sports.contains(sport),
                            accent: .movoLime,
                            action: { toggle(sport) }
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("HOW OFTEN, HONESTLY")
                            .font(.movoBody(11, weight: .semibold))
                            .tracking(0.5)
                            .foregroundStyle(scheme.movoTextSecondary)
                        Spacer()
                        Text("\(store.onboarding.sessionsPerWeek)")
                            .font(.movoDisplay(22))
                            .foregroundStyle(Color.movoLime)
                    }
                    Text("Sessions per week")
                        .font(.movoBody(13))
                        .foregroundStyle(scheme.movoTextPrimary)

                    HStack(spacing: 6) {
                        ForEach(1...7, id: \.self) { i in
                            Capsule()
                                .fill(i <= store.onboarding.sessionsPerWeek ? Color.movoLime : scheme.movoSurfaceAlt)
                                .frame(height: 26)
                                .onTapGesture { store.onboarding.sessionsPerWeek = i }
                        }
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous).fill(scheme.movoSurface))
            }
        }
    }

    private func toggle(_ sport: SportType) {
        if store.onboarding.sports.contains(sport) {
            store.onboarding.sports.remove(sport)
        } else {
            store.onboarding.sports.insert(sport)
        }
    }
}

#Preview {
    OnboardingSportsView(step: 1, onContinue: {}).environmentObject(AppStore())
}

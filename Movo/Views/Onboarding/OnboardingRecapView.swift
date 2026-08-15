import SwiftUI

struct OnboardingRecapView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    var step: Int

    private var experience: ExperienceLevel { store.onboarding.experience }
    private var resolvedStage: Stage { store.onboarding.resolvedStartStage }

    var body: some View {
        OnboardingScaffold(
            step: step,
            eyebrow: "Onboarding 3/3 — your starting Movo",
            title: "You start as a \(resolvedStage.displayName)",
            subtitle: subtitleText,
            buttonTitle: "Name your Movo",
            onContinue: {
                store.completeOnboarding()
            }
        ) {
            VStack(spacing: 16) {
                RoundedCard {
                    HStack {
                        Spacer()
                        CharacterPortrait(accent: .movoLime, stage: resolvedStage, mood: .happy, targetHeight: 190)
                        Spacer()
                    }
                }

                RecapRow(value: "\(store.onboarding.resolvedStartPoints) pts", label: "Starting balance, matched to your level")
                RecapRow(value: "×\(String(format: "%.1f", store.onboarding.resolvedMultiplier))", label: "Point multiplier — you're fitter, so reps count for less")
                RecapRow(value: "\(store.onboarding.sessionsPerWeek) / wk", label: "Weekly target you can change any time")

                RoundedCard {
                    Toggle(isOn: $store.onboarding.startFromEggAnyway) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start from the egg anyway")
                                .font(.movoBody(14, weight: .semibold))
                                .foregroundStyle(scheme.movoTextPrimary)
                            Text("Some people want the full journey")
                                .font(.movoBody(11))
                                .foregroundStyle(scheme.movoTextSecondary)
                        }
                    }
                    .tint(.movoLime)
                }
            }
        }
    }

    private var subtitleText: String {
        "\(store.onboarding.sessionsPerWeek) sessions a week already puts you ahead of the egg. Your Movo starts standing up."
    }
}

private struct RecapRow: View {
    @Environment(\.colorScheme) private var scheme
    var value: String
    var label: String

    var body: some View {
        RoundedCard {
            HStack(spacing: 14) {
                Text(value)
                    .font(.movoDisplay(18))
                    .foregroundStyle(Color.movoLime)
                    .frame(width: 78, alignment: .leading)
                Text(label)
                    .font(.movoBody(13))
                    .foregroundStyle(scheme.movoTextPrimary)
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    OnboardingRecapView(step: 2).environmentObject(AppStore())
}

import SwiftUI

struct OnboardingExperienceView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var scheme
    var step: Int
    var onContinue: () -> Void

    var body: some View {
        OnboardingScaffold(
            step: step,
            eyebrow: "Onboarding 1/3 — experience",
            title: "Where are you starting from?",
            subtitle: "Honest answers only — this sets your starting stage and how hard the points are to earn.",
            buttonTitle: "Continue",
            onContinue: onContinue
        ) {
            VStack(spacing: 10) {
                ForEach(ExperienceLevel.allCases) { level in
                    ExperienceRow(
                        level: level,
                        isSelected: store.onboarding.experience == level,
                        action: { store.onboarding.experience = level }
                    )
                }

                Text("Starting higher means a bigger character — and bigger point thresholds. Nobody coasts to Champion.")
                    .font(.movoBody(12))
                    .foregroundStyle(scheme.movoTextSecondary)
                    .padding(.top, 8)
            }
        }
    }
}

private struct ExperienceRow: View {
    @Environment(\.colorScheme) private var scheme
    var level: ExperienceLevel
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.movoBody(16, weight: .semibold))
                        .foregroundStyle(scheme.movoTextPrimary)
                    Text(level.subtitle)
                        .font(.movoBody(12))
                        .foregroundStyle(scheme.movoTextSecondary)
                }
                Spacer()
                Text(level.startStage.displayName.uppercased())
                    .font(.movoBody(10, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(isSelected ? Color.movoLime : scheme.movoTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                    .fill(scheme.movoSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: MovoMetrics.smallRadius, style: .continuous)
                    .strokeBorder(isSelected ? Color.movoLime : scheme.movoBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingExperienceView(step: 0, onContinue: {}).environmentObject(AppStore())
}
